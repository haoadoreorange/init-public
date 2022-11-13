// Overwrite titlebar firefox-css-fix
// // user_pref("browser.tabs.drawInTitlebar", false);

// user_pref("privacy.resistFingerprinting", true);
// Only send `Referer` header when the full hostnames match. (Note: if you notice significant breakage, you might try `1` combined with an `XOriginTrimmingPolicy` tweak below.)
user_pref("network.http.referer.XOriginPolicy", 1);
// When sending `Referer` across origins, only send scheme, host, and port in the `Referer` header of cross-origin requests.
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
// Disables sending additional analytics to web servers.
user_pref("beacon.enabled", false);
// Not rendering IDNs as their Punycode equivalent leaves you open to phishing attacks that can be very difficult to notice.
user_pref("network.IDN_show_punycode", true);
// Disable alt key used for alt menu shortcuts
user_pref("ui.key.menuAccessKey", 0);
// Remove alt menu focus
user_pref("ui.key.menuAccessKeyFocuses", false);

// user_pref("services.sync.prefs.sync.browser.tabs.drawInTitlebar", true);
user_pref("services.sync.prefs.sync.privacy.resistFingerprinting", true);
user_pref("services.sync.prefs.sync.network.http.referer.XOriginPolicy", true);
user_pref("services.sync.prefs.sync.network.http.referer.XOriginTrimmingPolicy", true);
user_pref("services.sync.prefs.sync.beacon.enabled", true);
user_pref("services.sync.prefs.sync.network.IDN_show_punycode", true);
user_pref("services.sync.prefs.sync.ui.key.menuAccessKey", true);
user_pref("services.sync.prefs.sync.ui.key.menuAccessKeyFocuses", true);
    
user_pref("services.sync.prefs.sync.browser.uiCustomization.state", true);
// user_pref("browser.uiCustomization.state", '{"placements":{"widget-overflow-fixed-list":["_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action","jid1-kkzogwgsw3ao4q_jetpack-browser-action","woop-noopscoopsnsxq_jetpack-browser-action","cookieautodelete_kennydo_com-browser-action","_af37054b-3ace-46a2-ac59-709e4412bec6_-browser-action","_testpilot-containers-browser-action","_c2c003ee-bd69-42a2-b0e9-6f34222cb046_-browser-action","chrome-gnome-shell_gnome_org-browser-action","addon_darkreader_org-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","jid1-om7ejgwa1u8akg_jetpack-browser-action","ublock0_raymondhill_net-browser-action","sponsorblocker_ajay_app-browser-action","contaner-proxy_bekh-ivanov_me-browser-action","_1c5e4c6f-5530-49a3-b216-31ce7d744db0_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","_b11bea1f-a888-4332-8d8a-cec2be7d24b9_-browser-action","default-bookmark-folder_gustiaux_com-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","canvasblocker_kkapsner_de-browser-action","_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action","leechblockng_proginosko_com-browser-action"],"nav-bar":["_tst-search-browser-action","add-ons-button","customizableui-special-spring1","urlbar-container","_955787d0-eb12-4903-86bc-0f8c49545c68_-browser-action","stop-reload-button","back-button","forward-button","open-file-button","emoji_saveriomorelli_com-browser-action","customizableui-special-spring2","downloads-button","_531906d3-e22f-4a6c-a102-8057b88a1a63_-browser-action","support_todoist_com-browser-action","_4853d046-c5a3-436b-bc36-220fd935ee1d_-browser-action","sync-button","tab-session-manager_sienori-browser-action","_windscribeff-browser-action","foxyproxy_eric_h_jung-browser-action","fxa-toolbar-menu-button","profile-switcher-ff_nd_ax-browser-action","containerise_kinte_sh-browser-action","webextension_metamask_io-browser-action","_d4e3bfcc-984f-47c2-818b-65e91103ce6c_-browser-action","_6ac85730-7d0f-4de0-b3fa-21142dd85326_-browser-action","_79b2e4de-8fb4-4ccc-b9f6-362ac2fb74b2_-browser-action","gt_giphy_com-browser-action","_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","firefox-view-button","new-tab-button","alltabs-button","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","support_todoist_com-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","_contain-facebook-browser-action","copyplaintext_eros_man-browser-action","addon_darkreader_org-browser-action","profile-switcher-ff_nd_ax-browser-action","_windscribeff-browser-action","treestyletab_piro_sakura_ne_jp-browser-action","_c2c003ee-bd69-42a2-b0e9-6f34222cb046_-browser-action","cookieautodelete_kennydo_com-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","tab-session-manager_sienori-browser-action","ublock0_raymondhill_net-browser-action","_4853d046-c5a3-436b-bc36-220fd935ee1d_-browser-action","_b11bea1f-a888-4332-8d8a-cec2be7d24b9_-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","contaner-proxy_bekh-ivanov_me-browser-action","_531906d3-e22f-4a6c-a102-8057b88a1a63_-browser-action","sponsorblocker_ajay_app-browser-action","woop-noopscoopsnsxq_jetpack-browser-action","_tst-search-browser-action","_af37054b-3ace-46a2-ac59-709e4412bec6_-browser-action","_955787d0-eb12-4903-86bc-0f8c49545c68_-browser-action","jid1-kkzogwgsw3ao4q_jetpack-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","chrome-gnome-shell_gnome_org-browser-action","_testpilot-containers-browser-action","containerise_kinte_sh-browser-action","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","default-bookmark-folder_gustiaux_com-browser-action","_1c5e4c6f-5530-49a3-b216-31ce7d744db0_-browser-action","webextension_metamask_io-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","jid1-om7ejgwa1u8akg_jetpack-browser-action","_d4e3bfcc-984f-47c2-818b-65e91103ce6c_-browser-action","_6ac85730-7d0f-4de0-b3fa-21142dd85326_-browser-action","emoji_saveriomorelli_com-browser-action","amptra_keepa_com-browser-action","jid1-mnnxcxisbpnsxq_jetpack-browser-action","_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action","_79b2e4de-8fb4-4ccc-b9f6-362ac2fb74b2_-browser-action","foxyproxy_eric_h_jung-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action","gt_giphy_com-browser-action","canvasblocker_kkapsner_de-browser-action","leechblockng_proginosko_com-browser-action","_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action","_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":21}');
