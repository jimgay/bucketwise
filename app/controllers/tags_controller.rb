class TagsController < ApplicationController
  before_filter :find_tag

  def show
    @page = (params[:page] || 0).to_i
    @more_pages, @items = tag_ref.tagged_items.page(@page)
  end

  def update
    tag_ref.update_attributes(params[:tag])
  end

  def destroy
    if params[:receiver_id].present?
      receiver = subscription.tags.find(params[:receiver_id])
      receiver.assimilate(tag_ref)
      redirect_to(receiver)
    else
      tag_ref.destroy
      redirect_to(subscription)
    end
  rescue ActiveRecord::RecordNotSaved => error
    head :unprocessable_entity
  end

  protected

    # can't call it 'tag' because that conflicts with the Rails 'tag()'
    # helper method. 'tag_ref' is lame, but sufficient.
    attr_reader :tag_ref
    helper_method :tag_ref

    def find_tag
      @tag_ref = Tag.find(params[:id])
      @subscription = user.subscriptions.find(@tag_ref.subscription_id)
    end

    def current_location
      if tag_ref
        "tags/%d" % tag_ref.id
      else
        super
      end
    end
end
