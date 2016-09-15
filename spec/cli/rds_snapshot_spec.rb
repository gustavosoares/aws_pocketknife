require 'rspec'
require 'spec_helper'

describe AwsPocketknife::Cli::RdsSnapshot do

  let(:db_name) {'test'}

  describe '#clean' do

    let(:days) { '15' }
    let(:dry_run) { true }

    it 'should call clean with dry_run true' do


      allow(AwsPocketknife::Rds).to receive(:clean_snapshots).with(db_name: db_name,
                                                             days: days,
                                                             dry_run: dry_run)
      expect(AwsPocketknife::Rds).to receive(:clean_snapshots).with(db_name: db_name,
                                                                   days: days,
                                                                   dry_run: dry_run)

      subject.clean db_name, days

    end

    it 'should call clean_ami with dry_run false' do

      dry_run = false

      allow(AwsPocketknife::Rds).to receive(:clean_snapshots).with(db_name: db_name,
                                                                   days: days,
                                                                   dry_run: dry_run)
      expect(AwsPocketknife::Rds).to receive(:clean_snapshots).with(db_name: db_name,
                                                                    days: days,
                                                                    dry_run: dry_run)

      subject.options = {:dry_run => dry_run}
      subject.clean db_name, days

    end

  end

  describe '#list' do


    it 'should call describe_snapshots with right arguments' do
      allow(AwsPocketknife::Rds).to receive(:describe_snapshots).with(db_name: db_name).and_return([])
      expect(AwsPocketknife::Rds).to receive(:describe_snapshots).with(db_name: db_name)

      subject.list db_name
    end
  end

end
