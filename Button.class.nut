// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT
//
// Description: Debounced button press with callbacks

class Button {
    static version = [1, 1, 0];

    static NORMALLY_HIGH = 1;
    static NORMALLY_LOW  = 0;

    _pin             = null;
    _pull            = null;
    _polarity        = null;
    _pressCallback   = null;
    _releaseCallback = null;

    constructor(pin, pull, polarity = null, pressCallback = null, releaseCallback = null) {
        _pin             = pin;
        _pull            = pull;

        if (polarity == null) {
            if (pull == DIGITAL_IN_PULLDOWN) polarity = NORMALLY_LOW;
            else polarity = NORMALLY_HIGH;
        }

        _polarity        = polarity;
        _pressCallback   = pressCallback;
        _releaseCallback = releaseCallback;

        _pin.configure(_pull, _debounce.bindenv(this));
    }

    function onPress(cb) {
        _pressCallback = cb;
        return this;
    }

    function onRelease(cb) {
        _releaseCallback = cb;
        return this;
    }

    /******************** PRIVATE FUNCTIONS (DO NOT CALL) ********************/
    function _debounce() {
        // Make sure callback isn’t triggered during debounce period
        _pin.configure(_pull);

        imp.wakeup(0.010, _getState.bindenv(this));  // Bounce times are usually limited to 10ms
    }

    function _getState() {
        if( _polarity == _pin.read() )
        {
            if(_releaseCallback != null)
            {
                _releaseCallback();
            }
        }
        else
        {
            if(_pressCallback != null)
            {
                _pressCallback();
            }
        }

        // Re-enabled callback after button action
        _pin.configure(_pull, _debounce.bindenv(this));
    }
}
