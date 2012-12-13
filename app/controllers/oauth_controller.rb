class OauthController < ApplicationController
  before_filter :authenticate_user!, :only => [:authorize, :allow]
  
  def authorize
    @oauth2 = OAuth2::Provider.parse(current_user, request)
    if @oauth2.redirect?
      redirect_to @oauth2.redirect_uri, :status => @oauth2.response_status
    else
      headers.merge!(@oauth2.response_headers)
      if @oauth2.response_body
        render :text => @oauth2.response_body, :status => @oauth2.response_status
      else
        session[:user_return_to] = request.original_fullpath
      end
    end
  end
  
  def allow
    @auth = OAuth2::Provider::Authorization.new(current_user, params)
    if params['allow'] == '1'
      @auth.grant_access!
    else
      @auth.deny_access!
    end
    redirect_to @auth.redirect_uri, :status => @auth.response_status
  end
end
