require 'sinatra'
require 'sinatra/json'
require 'dotenv'
Dotenv.load
require 'openssl'
require 'http'
require 'jwt'
require 'SecureRandom'

configure do
  # change to https://api.devicecheck.apple.com for production app, ie. App in App Store / Testflight
  set :device_check_api_url, 'https://api.development.devicecheck.apple.com'
  set :query_url, settings.device_check_api_url + '/v1/query_two_bits'
  set :update_url, settings.device_check_api_url + '/v1/update_two_bits'
end

get '/' do  
  "Please send the base 64 encoded device check token in JSON parameter key 'token' to POST /redeem"
end

post '/redeem' do
  begin
    request_payload = JSON.parse request.body.read
  rescue JSON::ParserError
    return json({ message: 'please supply a valid token parameter', redeemable: false })
  end

  # request_payload['token'] is the 'token' parameter we sent in the iOS app
  unless request_payload.key? 'token'
    return json({ message: 'please supply a token', redeemable: false })
  end

  response = query_two_bits(request_payload['token'])

  unless response.status == 200
    return json({ message: 'Error communicating with Apple server', redeemable: false })
  end

  begin
    response_hash = JSON.parse response.body
  rescue JSON::ParserError
    # if status 200 and no json returned, means the state was not set previously, we set them to nil / null
    response_hash = { bit0: nil, bit1: nil }
  end

  # if the bit0 has been set and set to true, means user has already redeemed using their phone
  if response_hash.key? 'bit0'
    if response_hash['bit0'] == true
      return json({ message: 'You have already redeemed it previously', redeemable: false })
    end
  end

  # update the first bit to true, and tell the iOS app user can redeem the free gift
  update_two_bits(request_payload['token'], true, false)

  json({ message: 'Congratulations!', redeemable: true })
end

def jwt_token
  private_key = File.read(ENV['DEVICE_CHECK_KEY_FILE'])
  key_id = ENV['DEVICE_CHECK_KEY_ID']
  team_id = ENV['DEVICE_CHECK_TEAM_ID']

  # Elliptic curve key, similar to login password, used for communication with apple server
  ec_key = OpenSSL::PKey::EC.new(private_key)
  jwt_token = JWT.encode({iss: team_id, iat: Time.now.to_i}, ec_key, 'ES256', {kid: key_id,})
end

def query_two_bits(device_token)
  payload = {
    'device_token' => device_token,
    'timestamp' => (Time.now.to_f * 1000).to_i,
    'transaction_id' => SecureRandom.uuid
  }

  response = HTTP.auth("Bearer #{jwt_token}").post(settings.query_url, json: payload)

  # if there is no bit state set before, apple will return the string 'Bit State Not Found' instead of json

  # if the bit state was set before, below will be returned
  #{"bit0":false,"bit1":false,"last_update_time":"2018-10"}
end

def update_two_bits(device_token, bit_zero, bit_one)
  payload = {
    'device_token' => device_token,
    'timestamp' => (Time.now.to_f * 1000).to_i,
    'transaction_id' => SecureRandom.uuid,
    'bit0': bit_zero,
    'bit1': bit_one
  }

  response = HTTP.auth("Bearer #{jwt_token}").post(settings.update_url, json: payload)
  # Apple will return status 200 with blank response body if the update is successful
end