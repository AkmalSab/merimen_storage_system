(function ($) {
    $.jq_easy_session_timeout = function (userSettings) {

        /* -------------------------------------------------- */
        // GLOBAL VARIABLES
        /* -------------------------------------------------- */

        let defaultSettings = {
            activityEvents: 'click keypress scroll wheel mousewheel mousemove',
            applicationId: 'easy_session_time_out',
            dialogMessage: 'Your session is about to expire.',
            dialogTimeRemainingLabel: 'You will be logged out in',
            dialogTitle: 'Session Expiration Warning',
            documentTitle: null,
            heartbeatCallback: null,
            heartbeatUrl: window.location.href,
            heartRate: 30,
            inactivityLogoutUrl: 'https://www.google.com',
            inactivityDialogDuration: 15,
            localStoragePrefix: null,
            logoutNowButtonText: 'Logout',
            manualLogoutUrl: null,
            maxInactivitySeconds: 900,
            stayLoggedInButtonText: 'Continue Session',
            manualStayLoggedInUrl: null
        };

        let settings = $.extend({}, defaultSettings, userSettings);

        // Set some fallback settings

        settings.documentTitle = settings.documentTitle || settings.dialogTitle;
        settings.localStoragePrefix = settings.localStoragePrefix || settings.applicationId;
        settings.manualLogoutUrl = settings.manualLogoutUrl || settings.inactivityLogoutUrl;

        let sessionStartTime;
        let heartbeatTimer;
        let inactivityTimer;
        let originalPageTitle = document.title;
        let localStorage = {};

        /* -------------------------------------------------- */
        // HEARTBEAT
        /* -------------------------------------------------- */

        /**
         * Makes an HTTP GET request to the provided URL.
         *
         * This is intended to be used as a "keep-alive" method to prevent users
         * sessions from expiring before the Idle Hands dialog appears.
         *
         * @param string heartbeat_url
         */
        let heartbeat = function (heartbeat_url) {
            $.get(heartbeat_url, function(data, textStatus, jqXHR) {
                if ($.isFunction(settings.heartbeatCallback)) {
                    settings.heartbeatCallback(data, textStatus, jqXHR);
                }
            });
        }

        /**
         * Starts the heartbeat at a rate of once every HEART_RATE number of
         * seconds.
         */
        let startHeartbeatTimer = function () {
            heartbeatTimer = setInterval(
                function () {
                    heartbeat(settings.heartbeatUrl);
                },
                (settings.heartRate * 1000)
            );
        }

        /**
         * Stops the heartbeat. x_x
         */
        let stopHeartbeatTimer = function () {
            clearInterval(heartbeatTimer);
        }

        /* -------------------------------------------------- */
        // CHECK INACTIVITY
        /* -------------------------------------------------- */

        /**
         * Checks how long the user has been inactive for and either logs the user
         * out, displays the inactivity dialog, or hides the inactivity dialog.
         */
        let checkInactivity = function () {
            let loggedOutStatus = getLoggedOutStatus();
            let sessionStartTime = getSessionStartTime();

            // Check that we were able to retrieve the logged out status and session
            // start time from local storage.

            if (typeof loggedOutStatus === 'boolean' && typeof sessionStartTime === 'number') {

                // If we have already been logged out elsewhere, logout here;
                // otherwise, calculate and handle inactivity.

                if (loggedOutStatus) {
                    logout();
                } else {
                    let elapsedSeconds = Math.floor(((new Date()).getTime() - sessionStartTime) / 1000);
                    let remainingSeconds = (settings.maxInactivitySeconds - elapsedSeconds);
                    let secondsLabel = (remainingSeconds == 1) ? 'second' : 'seconds';

                    $('#jquery-idle-hands-time-remaining').text(
                        remainingSeconds + ' ' + secondsLabel
                    );

                    /*
                     * If we are over our inactivity limit log the user out.
                     *
                     * Else, if we are within the inactivity dialog duration,
                     * stop tracking inactivity and show the dialog.
                     *
                     * Else, hide the dialog.
                     */

                    if (elapsedSeconds > settings.maxInactivitySeconds) {
                        logout(settings.inactivityLogoutUrl);
                    } else if (remainingSeconds <= settings.inactivityDialogDuration) {
                        $(document).off(settings.activityEvents, activityHandler);

                        showDialog();
                    } else {
                        hideDialog();
                    }
                }
            }
        }

        /**
         * Starts checking for inactivity every second.
         */
        let startInactivityTimer = function () {
            setSessionStartTime((new Date()).getTime());

            inactivityTimer = setInterval(checkInactivity, 1000);
        };

        /**
         * Stops checking for inactivity.
         */
        let stopInactivityTimer = function () {
            clearInterval(inactivityTimer);
        }

        /**
         * Stops checking inactivity and starts again with a new session start
         * time.
         */
        let restartInactivityTimer = function () {
            stopInactivityTimer();
            startInactivityTimer();
        }

        /**
         * An event handler intended to fire off when user activity is detected.
         *
         * @param Event event
         */
        let activityHandler = function (event) {
            restartInactivityTimer();
        }

        /* -------------------------------------------------- */
        // LOCAL STORAGE
        /* -------------------------------------------------- */

        /**
         * Set the wrapper used to manage local storage.
         */
        let initializeLocalStorage = function () {
            let config = {
                namespace: settings.localStoragePrefix,
                keyDelimiter: '.'
            };   

            localStorage.basil = new window.Basil(config);

            // Clear any previously set values

            flushLocalStorage();
        }

         /**
          * Set a value in local storage.
          *
          * @param string key
          * @param mixed  value
          */
        localStorage.set = function (key, value) {
            localStorage.basil.set(key, value);
        }

        /**
         * Retrieve a value from local storage.
         *
         * @param string key
         *
         * @return mixed
         */
        localStorage.get = function (key) {
            return localStorage.basil.get(key);
        }

        /**
         * Clear all values from local storage.
         */
        localStorage.flush = function () {
            localStorage.basil.reset();
        }

        /**
         * Sets the session start time in local storage.
         *
         * @param number time
         */
        let setSessionStartTime = function (time) {
            localStorage.set('sessionStartTime', time);

            sessionStartTime = time;
        }

        /**
         * Retrieves the session start time from local storage.
         *
         * @return number
         */
        let getSessionStartTime = function () {
            return localStorage.get('sessionStartTime');
        }

        /**
         * Sets the logout URL in local storage.
         *
         * @return string
         */
        let setLogoutUrl = function (logoutUrl) {
            localStorage.set('logoutUrl', logoutUrl);
        }

        /**
         * Sets the login URL in local storage.
         *
         * @return string
         */
         let setLoginUrl = function (loginUrl) {
            localStorage.set('loginUrl', loginUrl);
        }

        /**
         * Retrieves the logout URL from local storage.
         *
         * @return string
         */
        let getLogoutUrl = function () {
            return localStorage.get('logoutUrl');
        }

        /**
         * Retrieves the login URL from local storage.
         *
         * @return string
         */
         let getLoginUrl = function () {
            return localStorage.get('loginUrl');
        }

         /**
          * Clears values saved in local storage.
          */
        let flushLocalStorage = function () {
            localStorage.flush();
        }

        /**
         * Sets the logged out status in local storage.
         *
         * @param boolean
         */
        let setLoggedOutStatus = function (loggedOutStatus) {
            localStorage.set('loggedOutStatus', loggedOutStatus);
        }

        /**
         * Gets the logged out status from local storage.
         *
         * @return boolean
         */
        let getLoggedOutStatus = function () {
            return localStorage.get('loggedOutStatus');
        }

        /* -------------------------------------------------- */
        // DIALOG
        /* -------------------------------------------------- */

        /**
         * Creates the dialog window and attaches it to the body element.
         *
         * Uses inline styles and IDs whenever possible to prevent conflicts with
         * external libraries and/or style sheets.
         */
        let createDialog = function () {
            let dialogContainer = '<div id="jquery-idle-hands">' +
                                  '<div id="jquery-idle-hands-overlay"></div>' +
                                  '<div id="jquery-idle-hands-dialog">' +
                                  '<div id="jquery-idle-hands-dialog-title">' + settings.dialogTitle + '</div>' +
                                  '<div id="jquery-idle-hands-message-container">' +
                                  '<p id="jquery-idle-hands-message">' + settings.dialogMessage + '</p>' +
                                  '<p id="jquery-idle-hands-time-remaining-label">' + (settings.dialogTimeRemainingLabel + ': ') +
                                  '<span id="jquery-idle-hands-time-remaining"></span>' +
                                  '</p>' +
                                  '</div>' +
                                  '<hr/>' +
                                  '<div id="jquery-idle-hands-button-container">' +
                                  '<button id="jquery-idle-hands-stay-logged-in-button">' + settings.stayLoggedInButtonText + '</button>' +
                                  '<button id="jquery-idle-hands-logout-button">' + settings.logoutNowButtonText + '</button>' +
                                  '</div>' +
                                  '</div>' +
                                  '</div>';

            $('body').append(dialogContainer);

            // Stay Logged In button

            $('#jquery-idle-hands-stay-logged-in-button').on('click', function (event) {
                event.stopPropagation();

                //stayLoggedIn();
                continueSession(settings.manualStayLoggedInUrl);
            });

            // Logout button

            $('#jquery-idle-hands-logout-button').on('click', function (event) {
                event.stopPropagation();

                logout(settings.manualLogoutUrl);
            });
        }

        /**
         * Shows the dialog window.
         */
        let showDialog = function () {
            document.title = settings.documentTitle;

            $('#jquery-idle-hands').show(function () {
                //$('#jquery-idle-hands button').first().focus();
            });
        }

        /**
         * Hides the dialog window.
         */
        let hideDialog = function () {
            document.title = originalPageTitle;

            $('#jquery-idle-hands').hide();
        }

        /**
         * Logs the user out and redirects them to the logout URL.
         *
         * This checks local storage for a logout URL and redirects there; if
         * one was not previously set, this function sets it using the logoutURL
         * parameter before redirecting.
         *
         * @param string logoutUrl
         */
        let logout = function (logoutUrl) {
            if (logoutUrl) {
                setLogoutUrl(logoutUrl);
            } else {
                logoutUrl = getLogoutUrl();
            }

            // Check that we have a logout URL in case there was a problem getting
            // it from local storage, then redirect.

            if (logoutUrl) 
            {
                setLoggedOutStatus(true);

                stopHeartbeatTimer();
                stopInactivityTimer();

                $('#jquery-idle-hands-dialog').hide();

                if (typeof logoutUrl == 'function')
                {
                    logoutUrl('logoutUrl');
                }
                else
                {
                    window.location = logoutUrl;
                }
            }
        }

        /**
         * logged in as if they just loaded the page.
         */
        let continueSession = function (loginUrl) {
            if (loginUrl) {
                setLoginUrl(loginUrl);
            } else {
                loginUrl = getLoginUrl();
            }

            // Check that we have a logout URL in case there was a problem getting
            // it from local storage, then redirect.

            if (loginUrl) 
            {
                flushLocalStorage();

                setLoggedOutStatus(false);

                restartInactivityTimer();

                $(document).on(settings.activityEvents, activityHandler);

                hideDialog();

                if (typeof loginUrl == 'function')
                {
                    loginUrl('loginUrl');
                }
                else
                {
                    window.location = loginUrl;
                }
            }
        }

        /**
         * Clears local storage and resets the inactivity timer to keep the user
         * logged in as if they just loaded the page.
         */
        let stayLoggedIn = function () {
            flushLocalStorage();

            setLoggedOutStatus(false);

            restartInactivityTimer();

            $(document).on(settings.activityEvents, activityHandler);

            hideDialog();
        }
        
        let css = function(){

            var s1 ="#jquery-idle-hands{display:none;margin:0!important;padding:0!important;font-family:Roboto,Verdana,sans-serif!important;line-height:1.5!important;color:#333}#jquery-idle-hands-overlay{position:fixed!important;width:100%!important;height:100%!important;top:0!important;left:0!important;right:0!important;bottom:0!important;b1ackground-color:rgba(0,0,0,.25)!important;background-color:rgb(0 0 0 / 82%)!important;z-index:1001!important;margin:0!important;margin:0!important}#jquery-idle-hands-dialog{position:absolute!important;top:50%!important;left:50%!important;transform:translate(-50%,-50%)!important;z-index:1002!important;background-color:#fff!important;border-radius:4px!important;padding:4px!important;margin:0!important;min-width:300px!important;border:1px solid #000;font-family:Roboto,Verdana,sans-serif!important;line-height:1.5!important;color:#333}#jquery-idle-hands-dialog-title{color:#fff!important;text-align:center!important;background-color:red!important;border-radius:4px!important;padding:4px!important;margin:4px!important;text-align:center!important;line-height:1.5!important;font-family:Roboto,Verdana,sans-serif!important;font-size:16px}#jquery-idle-hands-message-container p{padding:0!important;margin:14px!important;text-align:left!important;line-height:1.5!important;font-family:Roboto,Verdana,sans-serif!important;color:#333;font-size:14px}#jquery-idle-hands hr{padding:0!important;margin:0 0 4px 0!important;border:1px solid silver!important;border-bottom:none!important;font-family:Roboto,Verdana,sans-serif!important;color:#333;line-height:1.5!important;height:1px!important}#jquery-idle-hands-button-container{text-align:center!important;margin:0!important;padding:0!important;font-family:Roboto,Verdana,sans-serif!important;color:#333;line-height:1.5!important}#jquery-idle-hands-button-container button{width:40%!important;padding:5px 0!important;font-size:14px;margin:5px 10px!important;line-height:1.5!important;font-family:Roboto,Verdana,sans-serif!important;color:#333}#jquery-idle-hands-stay-logged-in-button{background-color:green!important;color:#fff!important}";
            var str = ''
            +'<div class="easy_session_logout">'
                +'<style>'
                    + s1
                +'</style>'
            +'</div>';
            $(str).appendTo('body');
        }


        /* -------------------------------------------------- */
        // START IDLE HANDS
        /* -------------------------------------------------- */

        /**
         * Initializes Idle Hands.
         */
        let initialize = function () {
            
            css();

            initializeLocalStorage();

            setLoggedOutStatus(false);

            $(document).on(settings.activityEvents, activityHandler);

            createDialog();

            startHeartbeatTimer();
            startInactivityTimer();
        }



        
        $(document).ready(function($) 
        {
           $.getScript('https://cdnjs.cloudflare.com/ajax/libs/basil.js/0.4.10/basil.min.js', function(d) 
            {
                initialize();
            });
        });
    };
}(jQuery));