require './config/environment'
require "./app/models/user"

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    if logged_in?
      redirect to "/rides"
    else
  	  erb :index
    end
  end

  get "/signup" do
    if logged_in?
      redirect to "/rides"
    end
    erb :'/users/create_user'
  end

  get "/login" do
    if logged_in?
      redirect to "/rides"
    end
    erb :'/users/login'
  end

  get "/logout" do
    if logged_in?
      session.clear
      redirect to "/login"
    end
  end

  get "/rides/:id/edit" do
    if logged_in?
      @ride = Ride.find_by_id(params[:id])
      erb :'/rides/edit_ride'
    else
      redirect to "/login"
    end
  end

  patch "/rides/:id" do
    @ride = Ride.find_by_id(params[:id])
    if complete_ride?
      @ride.from_location = params["from_location"]
      @ride.to_location = params["to_location"]
      @ride.miles = params["miles"]
      @ride.day = params["day"]
      @ride.save
      
      @ride.feelings.each_with_index do |feeling, i|
        feeling.update(feeling_description: params["feelings"][i])
      end

      redirect to "/rides/#{@ride.id}"
    else
      redirect to "/rides/#{@ride.id}/edit"
    end
  end

  get "/rides/new" do
    if logged_in?
      erb :'/rides/create_ride'
    else
      redirect to "/login"
    end
  end

  get "/rides/:id" do
    if logged_in?
      @ride = Ride.find(params[:id])
      erb :'/rides/show_ride'
    else
      redirect to "/login"
    end
  end

  get "/rides" do
    if logged_in?
      @user = current_user
      erb :'rides/rides'
    else
      redirect to "/login"
    end
  end

  get "/failure" do
    erb :'/failure'
  end

  post "/signup" do
    user = User.new(email: params["email"], username: params["username"], password_digest: params["password"])
    if user.username != "" && user.password != "" && user.save
      session[:user_id] = user.id
      redirect "/rides"
    else
      redirect "/failure"
    end
  end

  post "/login" do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password_digest])
        session[:user_id] = user.id
        redirect "/rides"
    else
        redirect "/failure"
    end
  end

  post "/rides" do
    if logged_in? && complete_ride?
      @ride = Ride.create(
        from_location: params["from_location"],
        to_location: params["to_location"],
        miles: params["miles"],
        day: params["day"],
        user_id: session[:user_id]
      )
      params["feelings"].each do |feeling|
        @ride.feelings << Feeling.create(feeling_description: feeling)
      end
      redirect to "/rides"
    else
      redirect to "/rides/new"
    end
  end

  delete "/rides/:id/delete" do
    @ride = Ride.find(params[:id])
    if current_user.id == @ride.user_id
      @ride.delete
    end
    redirect to "/rides"
  end


  # Helper Methods
  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end

    def complete_ride?
      params["from_location"] != "" &&
      params["to_location"] != "" &&
      params["miles"] != "" &&
      params["day"] != ""
    end
  end

end
