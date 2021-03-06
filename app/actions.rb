# Homepage (Root path)
helpers do 
require 'date'
require 'active_support/all'

	def current_user 
		if session[:user_id]
		  @user = User.find(session[:user_id])
    end
	end

  def new_user
    User.new(
      first_name:   params[:first_name],
      email:        params[:email],
      password:     params[:password],
      phone_number: params[:phone_number] 
    )
  end

  def login_user
     @user = User.where(email: params[:email], password: params[:password]).first
  end

  def new_message(converted_time)
    Text.new(
      recipient_phone_number: params[:recipient_phone_number],
      content:                params[:content],
      user_id:                params[:id],
      send_time:              converted_time
    )
  end

  def new_group 
    GroupText.new(
      phone_num: params[:phone_num], 
      group_name: params[:group_name],
      users_id: params[:id]
      )
  end  

  def create_group_texts(converted_time)
    GroupText.where(group_name: params[:group]).each do |contact| 
      Text.create(
        recipient_phone_number: contact.phone_num,
        content: params[:content],
        send_time: converted_time,
        user_id: params[:id]
      )
    end 
  end 

  def group_names
    @groups = GroupText.where("users_id = ?", params[:id])
    names = []
    @groups.each do |c|
      names << c.group_name
    end 
    names
  end 

  def convert_time_zone(time_zone, input_time)
    case time_zone
    when "AKST"
      input_time = input_time + 9.hours
    when "PST"
      input_time = input_time + 8.hours 
    when "MST"
      input_time = input_time + 7.hours
    when "CST"
      input_time = input_time + 6.hours
    when "EST"
      input_time = input_time + 5.hours
    when "AST"
      input_time = input_time + 4.hours
    when "NST"
      input_time = input_time + 3.hours + 30.minutes
    end
    input_time
  end

  def delete
    @text.destroy
  end 

end 

post '/user/:id/texts/:text_id/pending/delete' do
  @text = Text.find(params[:text_id])
  @text.destroy!

  redirect "/user/#{session[:user_id]}/texts/pending"
end

post '/user/:id/texts/:text_id/archive/delete' do
  @text = Text.find(params[:text_id])
  @text.destroy!

  redirect "/user/#{session[:user_id]}/texts/archive"
end

get '/' do 
  @text_pending = Text.pending
  if current_user
    redirect "/user/#{session[:user_id]}"
  else
    erb :index 
  end
end

get '/user/new' do
  @text_pending = Text.pending
  erb :'users/new'
end

get '/login' do
  @text_pending = Text.pending
  erb :login
end

get '/user/:id' do
  @text_pending = Text.pending
  current_user
  erb :'users/show'
end

get '/user/:id/texts/pending' do
  @text_pending = Text.pending
  erb :'texts/pending'
end

get '/user/:id/texts/archive' do
  @text_pending = Text.pending
  @texts = Text.archive
  erb :'texts/archive'
end

post '/user/new' do
  @user = new_user
  if @user.save
    session[:user_id] = @user.id
    redirect "/user/#{session[:user_id]}"
  else
    erb :'users/new'
  end  
end

post '/login' do
  if login_user
    session[:user_id] = @user.id
    redirect "/user/#{session[:user_id]}"
  else
    erb :login
  end
end

post '/user/:id/text/new' do
  @text_pending = Text.pending
  current_user
  converted_time = convert_time_zone(params[:timezone], params[:datetime].to_datetime)
  @text = new_message(converted_time)
  if @text.save
    # @text.send_text(params[:recipient_phone_number], params[:content])
    redirect '/user/:id/texts/pending'
  else 
    erb :'users/show'
  end
end



get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get'/user/:id/group/new' do 
  @text_pending = Text.pending
  current_user
  erb :'groups/new'
end 

post '/user/:id/group/new' do 
  @text_pending = Text.pending
  current_user 
  @group = new_group 
  if @group.save
    redirect "/user/#{session[:user_id]}/group/show"
  else 
    erb :'users/show'
  end 
end 

get '/user/:id/group/send' do 
  @text_pending = Text.pending
  current_user
  group_names
  erb :'groups/send'
end 

get '/user/:id/group/show' do
  @text_pending = Text.pending 
  @groups = GroupText.where("users_id = ?", params[:id])
  @group_names = GroupText.select(:phone_num, :group_name).group(:group_name)
  erb :'groups/show'
end 

post '/user/:id/group/send' do 
  @text_pending = Text.pending
  current_user
  converted_time = convert_time_zone(params[:timezone], params[:send_time].to_datetime)
  create_group_texts(converted_time)
  redirect "/user/:id"
end 





