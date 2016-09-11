require 'rspec'
require 'spec_helper'

describe AwsPocketknife::Cli::Iam do

  let(:username) {'user'}
  let(:group_name) {'group'}

  describe '#list_ssl_certs' do

    it 'should call list_ssl_certs with the right arguments' do

      allow(AwsPocketknife::Iam).to receive(:list_ssl_certificates)
      expect(AwsPocketknife::Iam).to receive(:list_ssl_certificates)
      subject.list_ssl_certs

    end

  end

  describe '#create_user' do

    it 'should call method with the right arguments' do

      allow(AwsPocketknife::Iam).to receive(:create_iam_user).with(username)
      expect(AwsPocketknife::Iam).to receive(:create_iam_user).with(username)
      subject.create_user username

    end

  end

  describe '#create_group' do

    it 'should call method with the right arguments' do

      allow(AwsPocketknife::Iam).to receive(:create_group).with(group_name)
      expect(AwsPocketknife::Iam).to receive(:create_group).with(group_name)
      subject.create_group group_name

    end

  end

  describe '#add_user_to_group' do

    it 'should call method with the right arguments' do

      allow(AwsPocketknife::Iam).to receive(:add_user_to_group).with(username, group_name)
      expect(AwsPocketknife::Iam).to receive(:add_user_to_group).with(username, group_name)
      subject.add_user_to_group username, group_name

    end

  end

end
