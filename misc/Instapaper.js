var Instapaper, fixedEncodeURIComponent, qline2object;

Instapaper = (function() {
  function Instapaper() {}

  Instapaper.prototype.baseUrl = "https://www.instapaper.com/api/1/";

  Instapaper.prototype.consumer_key = 'SECRET';

  Instapaper.prototype.consumer_secret = 'TOPSECRET';

  Instapaper.prototype.generateNonce = function() {
    var length, nonce;
    nonce = [];
    length = 5;
    while (length > 0) {
      nonce.push((((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1));
      length--;
    }
    return nonce.join("");
  };

  Instapaper.prototype.getUTCtimestamp = function() {
    return (new Date((new Date).toUTCString())).getTime() / 1000;
  };

  Instapaper.prototype.authTemplate = function(req) {
    var auth;
    auth = "OAuth oauth_consumer_key=\"" + (fixedEncodeURIComponent(req.consumer_key)) + "\", ";
    if (req.token != null) {
      auth += "oauth_token=\"" + (fixedEncodeURIComponent(req.token)) + "\", ";
    }
    auth += ("oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"" + (fixedEncodeURIComponent(req.signature)) + "\", oauth_timestamp=\"" + (fixedEncodeURIComponent(req.timestamp)) + "\", oauth_nonce=\"" + (fixedEncodeURIComponent(req.nonce)) + "\", oauth_version=\"1.0\"").trim();
    return auth;
  };

  Instapaper.prototype.sigBaseTemplate = function(req) {
    var i, param_helper, param_string, params, sig, _i, _len, _ref;
    params = {
      oauth_consumer_key: req.consumer_key,
      oauth_nonce: req.nonce,
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: req.timestamp,
      oauth_version: '1.0'
    };
    if (req.token != null) {
      params.oauth_token = req.token;
    }
    if (req.data != null) {
      params = $.extend(params, req.data);
    }
    param_helper = [];
    _ref = Object.keys(params).sort();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      param_helper.push("" + (fixedEncodeURIComponent(i)) + "=" + (fixedEncodeURIComponent(params[i])));
    }
    param_string = param_helper.join('&');
    sig = "POST&" + (fixedEncodeURIComponent(this.baseUrl + req.url)) + "&" + (fixedEncodeURIComponent(param_string));
    return sig;
  };

  Instapaper.prototype.makeSigningKey = function() {
    var key;
    key = this.consumer_secret + '&';
    if (this.token_secret != null) {
      key += this.token_secret;
    }
    return key;
  };

  Instapaper.prototype.makeSignature = function(req) {
    var hmacGen;
    hmacGen = new jsSHA(this.sigBaseTemplate(req), "TEXT");
    return hmacGen.getHMAC(this.makeSigningKey(), "TEXT", "SHA-1", "B64");
  };

  Instapaper.prototype.makeRequestObject = function(options) {
    var req;
    req = $.extend({
      consumer_key: this.consumer_key,
      consumer_secret: this.consumer_secret,
      nonce: this.generateNonce(),
      timestamp: this.getUTCtimestamp(),
      token: this.token,
      token_secret: this.token_secret,
      method: 'POST'
    }, options);
    req.signature = this.makeSignature(req);
    return req;
  };

  Instapaper.prototype.request = function(options) {
    var auth, req;
    req = options.req || (options.req = this.makeRequestObject({
      url: options.url,
      data: options.data
    }));
    auth = this.authTemplate(options.req);
    return $.ajax({
      url: "" + this.baseUrl + options.url,
      dataType: (function() {
        return options.dataType || "json";
      })(),
      type: 'POST',
      data: options.data,
      headers: {
        Authorization: auth
      }
    });
  };

  Instapaper.prototype.requestToken = function(user, password) {
    var data, tokening, url;
    if (!((user != null) && (password != null))) {
      throw 'Please provide username and password.';
    }
    this.user = user;
    url = "oauth/access_token";
    data = {
      x_auth_username: user,
      x_auth_password: password,
      x_auth_mode: "client_auth"
    };
    tokening = this.request({
      url: url,
      req: this.makeRequestObject({
        url: url,
        data: data
      }),
      data: data,
      dataType: 'text'
    });
    tokening.done((function(_this) {
      return function(response) {
        data = qline2object(response);
        _this.token = data.oauth_token;
        return _this.token_secret = data.oauth_token_secret;
      };
    })(this));
    return tokening;
  };

  Instapaper.prototype.verifyCredentials = function() {
    return this.request({
      url: "account/verify_credentials"
    });
  };

  Instapaper.prototype.bookmarkList = function() {
    return this.request({
      url: "bookmarks/list"
    });
  };

  return Instapaper;

})();

if (typeof module !== "undefined" && module !== null) {
  module.exports = Instapaper;
}

qline2object = function(query) {
  var item, parts, result, _i, _len;
  if (query == null) {
    query = "";
  }
  result = {};
  parts = query.split("&");
  for (_i = 0, _len = parts.length; _i < _len; _i++) {
    item = parts[_i];
    item = item.split("=");
    result[item[0]] = item[1];
  }
  return result;
};

fixedEncodeURIComponent = function(str) {
  return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A');
};
