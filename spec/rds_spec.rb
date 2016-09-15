require 'rspec'
require 'spec_helper'

describe AwsPocketknife::Rds do

  let(:rds_client) {instance_double(Aws::RDS::Client)}
  let(:db_name) { 'my_db' }
  let(:snapshot_name) { 'db_snapshot_1' }

  before (:each) do
    allow(subject).to receive(:rds_client).and_return(rds_client)
  end

  describe '#describe_snapshots' do
    it 'should get snapshots' do
      allow(rds_client).to receive(:describe_db_snapshots).with({db_instance_identifier: db_name})
      expect(rds_client).to receive(:describe_db_snapshots).with({db_instance_identifier: db_name})

      subject.describe_snapshots db_name: db_name
    end
  end

  describe '#clean_snapshots' do
    it 'should clean snapsthos when dry_run is false' do
      aws_reponse = describe_snapshot_response db_snapshot_identifier: snapshot_name, date: '2040-12-16 11:57:42 +1100'

      allow(rds_client).to receive(:describe_db_snapshots)
                               .with({db_instance_identifier: db_name})
                               .and_return(aws_reponse)
      allow(rds_client).to receive(:delete_db_snapshot)
                               .with({db_snapshot_identifier: snapshot_name})

      expect(rds_client).to receive(:describe_db_snapshots).with({db_instance_identifier: db_name})
      expect(rds_client).to receive(:delete_db_snapshot).with({db_snapshot_identifier: snapshot_name})

      subject.clean_snapshots db_name: db_name, days: 15, dry_run: false
    end

    it 'should not clean snapsthos when dry_run is true' do
      aws_reponse = describe_snapshot_response db_snapshot_identifier: snapshot_name, date: '2040-12-16 11:57:42 +1100'

      allow(rds_client).to receive(:describe_db_snapshots)
                               .with({db_instance_identifier: db_name})
                               .and_return(aws_reponse)
      allow(rds_client).to receive(:delete_db_snapshot)
                               .with({db_snapshot_identifier: snapshot_name})

      expect(rds_client).to receive(:describe_db_snapshots).with({db_instance_identifier: db_name})
      expect(rds_client).not_to receive(:delete_db_snapshot).with({db_snapshot_identifier: snapshot_name})

      subject.clean_snapshots db_name: db_name, days: 15, dry_run: true
    end
  end


end