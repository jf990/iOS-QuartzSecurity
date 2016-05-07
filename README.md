# iOS-QuartzSecurity
An iOS app demonstrating how to use Quartz runtime authentication services.

## Project Purpose
The goal here is to demonstrate the usage of the main authentication services:

  * [AGSAuthenticationManager](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_authentication_manager.html)
  * [AGSAuthenticationManagerDelegate](https://developers.arcgis.com/ios/beta/api-reference/protocol_a_g_s_authentication_manager_delegate-p.html)
  * [AGSAuthenticationChallenge](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_authentication_challenge.html)
  * [AGSCredential](https://developers.arcgis.com/ios/beta/api-reference/interface_a_g_s_credential.html)


In order to do this we need a developers account on [ArcGIS for Developers](https://developers.arcgis.com/account/profile/).

To get started for the first time, follow the [iOS Quartz SDK setup instructions](https://developers.arcgis.com/ios/beta/swift/guide/install.htm).

## API Design Issues

My opinion, there are flaws in the current API design:

* There is no way to login without requesting a portal item. AGSAuthenticationManager or AGSPortal should have a method to login. The forced login would use the AGSAuthenticationChallenge flow. With AGSAuthenticationManager the issue is there is no way to indicate what your portal is (it's on the AGSPortal object).
* Any login of any kind should fire a callback/signal/delegate so the developer can know a successful/failed login attempt has been completed. You cannot use, for example, a successful load of a portal item, because you have no way of knowing post load if that portal item actually requested a login.
* Error 499 should trigger a login.
