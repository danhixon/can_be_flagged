require 'test/unit'
require 'logger'
require File.expand_path(File.dirname(__FILE__) + '/../rails/init')

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class FlagThisTest < Test::Unit::TestCase

  def setup_flags
    require File.expand_path(File.dirname(__FILE__) + '/../lib/generators/flag/templates/create_flags') 
    CreateFlags.up
    load(File.expand_path(File.dirname(__FILE__) + '/../lib/generators/flag/templates/flag.rb'))
  end

  def setup_test_models
    load(File.expand_path(File.dirname(__FILE__) + '/schema.rb'))
    load(File.expand_path(File.dirname(__FILE__) + '/models.rb'))
  end

  def setup
    setup_flags
    setup_test_models
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_create_flag
    post = Post.create(:text => "Awesome post !")
    assert_not_nil post.flags.create().id

    reply = Reply.create(:text => "I want you to buy some enlarging products.")
    assert_not_nil reply.spam_flags.create(:comment => "this is definately spam.").id
    assert_not_nil reply.offensive_flags.create(:comment => "this is offensive to me.").id
    assert_raise NoMethodError do
      reply.flags.create(:comment=>"unspecific flag")
    end
  end

  def test_fetch_flags
    post = Post.create(:text => "Awesome post !")
    post.flags.create(:comment => "This is the first flag.")
    flaggable = Post.find(1)
    assert_equal 1, flaggable.flags.length
    assert_equal "This is the first flag.", flaggable.flags.first.comment

    reply = Reply.create(:text => "You should check out my website instead!")
    offensive_flag = reply.offensive_flags.create(:comment => "I am so offended!")
    assert_equal [offensive_flag], reply.offensive_flags
    spam_flag = reply.spam_flags.create(:comment => "I can't stand the spam!")
    assert_equal [spam_flag], reply.spam_flags
  end

  def test_find_flags_for_flaggable
    post = Post.create(:text => "Awesome Post Part Deux.")
    flag = post.flags.create(:comment => "This is the first flag.")
    assert_equal [flag], Flag.find_flags_for_flaggable(post.class.name, post.id)
  end

  def test_find_flaggable
    post = Post.create(:text => "Awesome post Parte Two")
    flag = post.flags.create(:comment => "This is the first flag.")
    assert_equal post, Flag.find_flaggable(post.class.name, post.id) 
  end

  def test_find_flags_for
    post = Post.create(:text => "Awesome post !")
    flag = post.flags.create(:comment => "This is the first flag.")
    assert_equal [flag], Post.find_flags_for(post)

    reply = Reply.create(:text => "Shimmering Splendorous Sausage")
    offensive_flag = reply.offensive_flags.create(:comment => "gross!")
    assert_equal [offensive_flag], Reply.find_offensive_flags_for(reply)

    spam_flag = reply.spam_flags.create(:comment => "I'm sick of sausage ads")
    assert_equal [spam_flag], Reply.find_spam_flags_for(reply)
  end

  def test_find_flags_by_user
    user = User.create(:name => "Mike")
    user2 = User.create(:name => "Fake") 
    post = Post.create(:text => "Awesome post!")
    flag = post.flags.create(:comment => "This is the first flag.", :user => user)
    assert_equal true, Post.find_flags_by_user(user).include?(flag)
    assert_equal false, Post.find_flags_by_user(user2).include?(flag)
    
    reply = Reply.create(:text => "What would thousands of new visitors mean for your business?")
    spam_flag = reply.spam_flags.create(:comment => "Stop selling stuff in replies!", :user => user)
    assert_equal [spam_flag], Reply.find_spam_flags_by_user(user)

    offensive_flag = reply.offensive_flags.create(:comment => "Offended!!", :user => user)
    assert_equal [offensive_flag], Reply.find_offensive_flags_by_user(user)
  end

  def test_add_flag
    post = Post.create(:text => "Super Post of a Post")
    flag = Flag.new(:comment => 'I am not happy about this.')
    post.add_flag(flag)
    assert_equal [flag], post.flags

    reply = Reply.create(:text => "I am so eager to try something else right now.")
    spam_flag = Flag.new(:comment => 'super spammy')
    reply.add_spam_flag(spam_flag)
    assert_equal [spam_flag], reply.spam_flags

    offensive_flag = Flag.new(:comment => 'super offensive')
    reply.add_offensive_flag(offensive_flag)
    assert_equal [offensive_flag], reply.offensive_flags
  end

  def test_is_flag_type
    post = Post.create(:text => "Terrible Post")
    flag = Flag.new(:comment => 'Super flag')
    post.add_flag(flag)
    assert_equal true, flag.is_flag_type?(:abuse)

    reply = Reply.create(:text => "Happy people live longer")
    
    flag = Flag.new(:comment => "That is unfounded and thereby offensive.")
    reply.add_offensive_flag(flag)
    assert_equal true, flag.is_flag_type?(:offensive)

    spam = Flag.new(:comment => 'Stop trying to sell happiness. It not work.')
    reply.add_spam_flag(spam)
    assert_equal true, spam.is_flag_type?(:spam)
    assert_equal false, spam.is_flag_type?(:abuse)

  end

end
