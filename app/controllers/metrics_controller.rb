class MetricsController < ApplicationController
  before_action :fetch_metrics, only: :index
  before_action :fetch_users, only: :show
  before_action :fetch_user, only: [:save, :create]
  
  def index
    @metrics.each do |metric|
      metric['id'] = metric['href'].split('/')[4]
    end
  end

  def create
    @metric_id = params['metric_id']
    @metric_name = params['metric_name']
    @user_id = params['user_id']
  end


  def save
    @owner = { "kind" => "user", "href" => @user['href'] }
    @value = params['metric_value_data']
    @new_metric_value = { "owner" => @owner, "value" => @value.to_f }
    print "========================================================="
    print @new_metric_value
    print "========================================================="
    @metric_id = params['metric_id']
    @metric_name = params['metric_name']
    if create_metric_value(@metric_id,@new_metric_value)
     redirect_to controller: "metrics", action: "show", id: @metric_id, name: @metric_name
    end
  end

  def show
    @metric_values = fetch_metric_values(params['id'])
    @metric_values_of_type_user = @metric_values.select{ |metric_value| metric_value['owner']['kind'] == 'user'}
    print @metric_values_of_type_user
    @users_with_metrics = @users.each do |user|
      user['id'] = user['href'].split('/')[4]
      @metric_values_of_type_user.each do |metric|
        if metric['owner']['href'] == user['href']
            user['metric_value'] = metric['value']
            user['metric_id'] = params['id']
            user['metric_value_id'] = metric['href'].split('/')[6]
            user['metric_name'] = @metric_name
        end
      end
    end
  end

  def fetch_metric_values(id)
    url = "/metrics/#{id}/values"
    headers = { 'Accept' => 'application/vnd.hoopla.metric-values-list' }
    return @hoopla_client.get(url,headers)
  end

  private
  def fetch_metrics
    url = '/metrics'
    headers = { 'Accept' => 'application/vnd.hoopla.metric-list' }
    @metrics = @hoopla_client.get(url,headers)
  end

  def fetch_user
    userUrl = "/users/#{params['user_id']}"
    userHeaders = { 'Accept' => 'application/vnd.hoopla.user-list' }
    @user = @hoopla_client.get(userUrl,userHeaders)
  end

  def fetch_users
    userUrl = "/users"
    userHeaders = { 'Accept' => 'application/vnd.hoopla.user-list' }
    @users = @hoopla_client.get(userUrl,userHeaders)
  end

  def create_metric_value(id,data)
    url = "metrics/#{id}/values"
    return @hoopla_client.post(url,data)
  end
end
