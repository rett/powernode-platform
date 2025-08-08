# frozen_string_literal: true

class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :refresh]

  # POST /api/v1/sessions
  def create
    user = User.find_by(email: login_params[:email]&.downcase)
    
    if user&.authenticate(login_params[:password])
      if user.active? && user.account.active?
        tokens = JwtService.generate_tokens(user)
        user.record_login!
        
        render json: {
          user: user_data(user),
          account: account_data(user.account),
          tokens: tokens
        }, status: :ok
      else
        render json: { 
          error: 'Account suspended or user inactive' 
        }, status: :forbidden
      end
    else
      render json: { 
        error: 'Invalid email or password' 
      }, status: :unauthorized
    end
  end

  # POST /api/v1/sessions/refresh
  def refresh
    tokens = JwtService.refresh_access_token(params[:refresh_token])
    
    render json: { tokens: tokens }, status: :ok
  rescue StandardError => e
    render json: { 
      error: 'Invalid refresh token',
      message: e.message 
    }, status: :unauthorized
  end

  # DELETE /api/v1/sessions
  def destroy
    # In a stateless JWT system, logout is handled client-side
    # But we could implement token blacklisting here if needed
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  # GET /api/v1/sessions/current
  def current
    render json: {
      user: user_data(current_user),
      account: account_data(current_account)
    }, status: :ok
  end

  private

  def login_params
    params.require(:session).permit(:email, :password)
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role,
      status: user.status,
      email_verified: user.email_verified?,
      last_login_at: user.last_login_at
    }
  end

  def account_data(account)
    {
      id: account.id,
      name: account.name,
      subdomain: account.subdomain,
      status: account.status
    }
  end
end