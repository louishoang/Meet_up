require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end

  def new_meetup?(name, description)
    !Meetup.exists?(name: name, description: description)
  end
end # End of class

def already_member?(user_id, meetup_id)
  Membership.where(user_id: user_id, meetup_id: meetup_id).exists?
end

def get_members(meetup_id)
  @members_list = User.joins(:memberships)
  @members_list.where(meetup_id: meetup_id)
  # @members_list = Membership.joins(:users).collect{|membership| membership.users.map{|user| user.attributes.merge(membership.attributes)}}
end


get '/' do
  @meetups = Meetup.all.order('name')
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end


get '/meetups/:id' do
  @meetup = Meetup.find(params[:id])

  if signed_in?
    @already_member = already_member?(current_user.id, params[:id])
  end
  get_members(@meetup)


  erb :'meetups/show'
end

get '/new' do
  authenticate!
  erb :'meetups/new'
end

post '/new' do
  name = params[:meetup_name]
  location = params[:location]
  description = params[:description]
  if new_meetup?(name, description)
    flash[:notice] = "New meetup added successfully."
  end
  @new_meetup = Meetup.find_or_create_by(name: name, location: location, description: description)
  redirect "/meetups/#{@new_meetup.id}"
end

post '/join' do
  @fields = {user_id: params[:user_id], meetup_id: params[:meetup_id], role: params[:meetup_id]}
  if !authenticate!
    flash[:notice] = "You must sign in."
  else
    @new_member = Membership.find_or_create_by(@fields)
    flash[:notice] = "You just joined the group, congratulation!"
  end
  redirect "/meetups/#{@fields[:meetup_id]}"
end

post '/leave' do
  @fields = {user_id: params[:user_id], meetup_id: params[:meetup_id], role: params[:meetup_id]}
  @leave_member = Membership.where(@fields).destroy_all
  flash[:notice] = "You have left the group"
  redirect "/meetups/#{@fields[:meetup_id]}"
end
