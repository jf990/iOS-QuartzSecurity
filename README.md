# iOS-QuartzSecurity
An iOS app demonstrating how to use Quartz runtime authentication services.

## Project Purpose
The goal here is to demonstrate the usage of the main authentication services:

  * [AGSAuthenticationManager](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_authentication_manager.html)
  * [AGSAuthenticationManagerDelegate](https://developers.arcgis.com/ios/beta/api-reference/protocol_a_g_s_authentication_manager_delegate-p.html)
  * [AGSAuthenticationChallenge](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_authentication_challenge.html)
  * [AGSCredential](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_credential.html)
  * [AGSPortal](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_portal.html)
  * [AGSPortalItem](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_portal_item.html)

In order to do this we need a developers account on [ArcGIS for Developers](https://developers.arcgis.com/account/profile/).

To get started for the first time, follow the [iOS Quartz SDK setup instructions](https://developers.arcgis.com/ios/beta/swift/guide/install.htm).

## App Open Issues

There are a few outstanding issues with this app, to be solved before we finalize the tutorial:

* We need a way to accurately manage the users logged in state. I think any time a login completes (either success or failure) then a callback should be made. For example, AuthenticationManager:didCompleteAuthenticationChallenge(challenge, error)

* I receive error 499 while attempting to access a private item and I am not logged in. This should trigger a login.

* I receive error -999 when attempting to access a private item and I am not logged in. Says "cancelled" but I didn't cancel it.'"

* I receive error 8 on a private item, that may be a layer and not a map. This may be OK but I need to check it.

* There are no items on my account - yet I have items. I need to figure out how to get AGSPortal.findItemsWithQueryParams to work.
