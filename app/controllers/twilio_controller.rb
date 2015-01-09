require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
  skip_before_action :verify_authenticity_token
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def sms
    tasks = Task.where(:assigned_phone => params['From'])
    if tasks.any?
      @task = tasks.last
      state = @task.state

      body = params['Body']
      if body.start_with?("Sent from your Twilio trial account - ")
        body = body["Sent from your Twilio trial account - ".length,body.length]
      end

      if @task.state == 'waiting_response'
        state = 'conversation'
      end

      response_message = ''
      if @task.state == 'waiting_response' or @task.state == 'conversation'
        if ["si", "ok", "de acuerdo", "d'acord", "good"].include?(body.downcase)
          state = 'accepted'
          response_message = 'OK, pues ya me avisaras si hay algun problema'
        elsif ["no", "no puedo"].include?(body.downcase)
          state = 'rejected'
          response_message = 'OK, ya buscare a alguien'
        end
      end
      @task.update_attributes(:state => state, :last_message => body, :last_message_state => params['SmsStatus'], :last_message_sid => params['SmsSid'])
    end

    if response_message.blank?
      response = Twilio::TwiML::Response.new do |r|
      end
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Message response_message
      end
      # save a random sid so that the model knows it must create a new log for this task
      sid = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
      @task.update_attributes(:last_message => response_message, :last_message_sid => sid)
    end

    render_twiml response
  end

  def status
    @task = Task.find(params[:task_id])
    @task.update_attributes(:last_message_state => params['SmsStatus'], :last_message_sid => params['SmsSid'])
   
    # send back an empty response
    render_twiml Twilio::TwiML::Response.new
  end

end