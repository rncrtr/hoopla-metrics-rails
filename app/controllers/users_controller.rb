class UsersController < ApplicationController
  require 'json'
  before_action :fetch_user

  def edit
    print params
    @metric_value = fetch_metric_value(params['metric_id'],params['metric_value_id'])
    @metric_id = params['metric_id']
    @metric_value_id = params['metric_value_id']
    @metric_name = params['metric_name']
  end

  def update
    print params
    @metric_id = params['metric_id']
    @metric_value_id = params['metric_value_id']
    @metric_name = params['metric_name']
    if params['create_value'] == true
      
    else
      @updated_metric_value = fetch_metric_value(params['metric_id'],params['metric_value_id'])
      @updated_metric_value['value'] = params['metric_value_data'].to_f
      print "UPDATED:",@updated_metric_value
      if update_metric_value(@metric_id,@metric_value_id,@updated_metric_value)
        redirect_to controller: "metrics", action: "show", id: @metric_id, name: @metric_name
      end
    end
  end

  private
  def fetch_user
    userUrl = "/users/#{params['id']}"
    userHeaders = { 'Accept' => 'application/vnd.hoopla.user-list' }
    @user = @hoopla_client.get(userUrl,userHeaders)
  end

  def fetch_metric_value(id,value_id)
    url = "/metrics/#{id}/values/#{value_id}"
    headers = { 'Accept' => 'application/vnd.hoopla.metric-value' }
    return @hoopla_client.get(url,headers) || false
  end

  def update_metric_value(id,value_id,data)
    url = "metrics/#{id}/values/#{value_id}"
    return @hoopla_client.put(url,data)
  end
end
