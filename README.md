# DeviceCheckerServer

Backend server code for communicating with Apple's Device Check API.

You will need an Apple Developer account before proceeding.



## Deploy to Heroku instruction :

1. Go to [https://developer.apple.com/account/ios/authkey/](https://developer.apple.com/account/ios/authkey/) and create a new key by clicking the '**+**' button.

2. Give the key a name, check '**DeviceCheck**' in the Key Services, click '**Continue**', then download the key. Copy the **Key ID** shown on the download page as well.
3. Create an app in Heroku panel, then go to **Settings** tab, and add **Config Vars** like this :

![configVar](README_asset/configVar.png)

4. Add **DEVICE_CHECK_KEY_ID**, **DEVICE_CHECK_TEAM_ID** and **DEVICE_CHECK_KEY_STRING** into config vars.

![configVar2](README_asset/configVar2.png)

5. The value of DEVICE_CHECK_KEY_ID is the Key ID you copied on step 2.
6. The value of DEVICE_CHECK_TEAM_ID is your [Apple developer account Team ID](https://developer.apple.com/account/#/membership).
7. The value of DEVICE_CHECK_KEY_STRING is the content of the key file (.p8) you downloaded. You can open the key file using TextEdit app, it should start with '-----BEGIN PRIVATE KEY-----' , copy the whole text in the file (including the line 'begin private key' and 'end private key') and paste it to Heroku.
8. Link this repository (or your Fork) in the **Deploy** tab of the Heroku app, then click 'Deploy Branch' 🚀
9. Your iOS app should can connect to https://your-app.heroku.com/reward or https://your-app.heroku.com/reset



## Local Usage instruction :

1. Go to [https://developer.apple.com/account/ios/authkey/](https://developer.apple.com/account/ios/authkey/) and create a new key by clicking the '**+**' button.
2. Give the key a name, check '**DeviceCheck**' in the Key Services, click '**Continue**', then download the key. Copy the **Key ID** shown on the download page as well.
3. Download/Fork this repository, edit the file **.env.example** . 
4. Replace **DEVICE_CHECK_KEY_ID** with the Key ID you copied earlier.
5. Replace **DEVICE_CHECK_TEAM_ID** with your team ID, you can retrieve this value here : [https://developer.apple.com/account/#/membership](https://developer.apple.com/account/#/membership)
6. Replace **DEVICE_CHECK_KEY_STRING** with the content of the key file (.p8) you downloaded earlier. You can open this file with TextEdit app.
7. Rename the file **.env.example** to **.env**
8. Open terminal, navigate to this repo folder, run `bundle install` , then run `ruby app.rb` to run the server code.
9. Your iOS app should can connect to https://localhost:4567/reward or https://localhost:4567/reset



