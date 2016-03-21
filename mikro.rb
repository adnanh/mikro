require 'sinatra'
require_relative 'lib/init'

use Rack::Session::Cookie, CONFIG['cookie']

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

not_found do
  erb :not_found
end

get '/' do
  posts = Post.order(Sequel.desc(:created_at))

  posts_by_year = posts.all.group_by { |post| post[:created_at].year.to_s }
  posts_by_year.each { |year, posts| posts_by_year[year] = posts.group_by { |post| post[:created_at].strftime('%B') } }

  erb :index, locals: {posts_by_year: posts_by_year, all_posts: posts}
end

get '/post/new' do
  if session[:logged_in]
    erb :new_post, locals: {body: params[:body]}
  else
    session[:return_url] = "/post/new?body=#{URI.escape(params[:body])}"
    redirect '/login'
  end
end

get '/post/:id' do
  post = Post.where(:id => params[:id].to_i).first

  if post.nil?
    404
  else
    erb :post, locals: {post: post}
  end
end

get '/post/:id/update' do
  if session[:logged_in]
    post = Post.where(:id => params[:id].to_i).first

    if post.nil?
      404
    else
      erb :update_post, locals: {post: post}
    end
  else
    session[:return_url] = "/post/#{params[:id].to_i}/update"
    redirect '/login'
  end
end

get '/post/:id/delete' do
  if session[:logged_in]
    affected = Post.where(:id => params[:id].to_i).delete
    if affected == 0
      404
    else
      redirect '/'
    end
  else
    session[:return_url] = "/post/#{params[:id].to_i}/delete"
    redirect '/login'
  end
end

get '/login' do
  if session[:logged_in]
    redirect '/'
  else
    erb :login, locals: {error: params[:error]}
  end
end

get '/logout' do
  if session[:logged_in]
    session.clear
  end

  redirect '/'
end

post '/post' do
  if session[:logged_in]
    unless params[:body].nil? || params[:body].empty?
      post = Post.new
      post.body = params[:body]
      post.save
    end
  end

  redirect '/'
end

post '/post/:id' do
  if session[:logged_in]
    post = Post.where(:id => params[:id].to_i).first

    unless post.nil?
      post.update({body: params[:body]})
      post.save
    end
  end

  redirect '/'
end

post '/login' do
  if params[:password] == CONFIG['settings']['password']
    session[:logged_in] = true
    return_url = session[:return_url]

    if return_url.nil? || return_url.empty?
      redirect '/'
    else
      session.delete :return_url
      redirect return_url
    end
  else
    redirect '/login?error=true'
  end
end
