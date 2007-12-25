require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  define_models
  
  it "finds topic" do
    posts(:default).topic.should == topics(:default)
  end
  
  it "requires body" do
    p = new_post(:default)
    p.body = nil
    p.should_not be_valid
    p.errors.on(:body).should_not be_nil
  end
end

describe Post, "being deleted" do
  define_models do
    model Post do
      stub :second, :body => 'second', :created_at => current_time - 6.days
    end
  end
  
  it "fixes last_user_id" do
    topics(:default).last_user_id = 1; topics(:default).save
    posts(:default).destroy
    topics(:default).reload.last_user.should == users(:default)
  end
  
  it "fixes last_updated_at" do
    posts(:default).destroy
    topics(:default).reload.last_updated_at.should == posts(:second).created_at
  end
  
  it "fixes #last_post" do
    topics(:default).recent_post.should == posts(:default)
    posts(:default).destroy
    topics(:default).recent_post(true).should == posts(:second)
  end
end

describe Post, "being deleted as sole post in topic" do
  define_models
  
  it "clears topic" do
    posts(:default).destroy
    lambda { topics(:default).reload }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe Post, "#editable_by?" do
  before do
    @user  = mock_model User
    @post  = Post.new
  end

  it "allows user" do
    @user.should_receive(:admin?).and_return(false)
    @user.should_receive(:moderator_of?).and_return(false)
    @post.should_not be_editable_by(@user)
  end

  it "restricts user for other post" do
    @post.user_id = @user.id
    @post.should     be_editable_by(@user)
  end
  
  it "allows admin" do
    @user.should_receive(:admin?).and_return(true)
    @post.should be_editable_by(@user)
  end
  
  it "restricts moderator for other forum" do
    @user.should_receive(:admin?).and_return(false)
    @user.should_receive(:moderator_of?).with(1).and_return(false)
    @post.forum_id = 1
    @post.should_not be_editable_by(@user)
  end
  
  it "allows moderator" do
    @user.should_receive(:admin?).and_return(false)
    @user.should_receive(:moderator_of?).with(2).and_return(true)
    @post.forum_id = 2
    @post.should     be_editable_by(@user)
  end
end