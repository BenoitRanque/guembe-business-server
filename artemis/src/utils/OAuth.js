class OAuth {
  constructor (endpoint, {
    clientId,
    clientSecret,
    scope,

  }) {

  }
}

class FacebookOAuth extends OAuth {

}

class GoogleOAuth extends OAuth {

}


// send XSRF token in state. Set as short lived http only cookie on client before redirect


// clas responsabilities
// generate initial redirect url
//    pass any query parameters in state
// verify response and extract information
// extract original query parameters from response state, use those on final redirect
