require 'spec_helper'

describe ToSpreadsheet::XLSX do
  let(:spreadsheet) {
    html  = Haml::Engine.new(TEST_HAML).render
    xls_io = ToSpreadsheet::XLSX.to_io(html)
    Spreadsheet.open(xls_io)
  }

  it 'creates multiple worksheets' do
    spreadsheet.should have(2).worksheets
  end

  it 'supports num format' do
    spreadsheet.worksheet(0)[1, 1].should == 20
  end

  it 'support float format' do
    spreadsheet.worksheet(1)[1, 1].class.should be(Float)
  end

  it 'supports date format' do
    spreadsheet.worksheet(0)[1, 2].class.should be(Date)
  end

  it 'parses null dates' do
    spreadsheet.worksheet(0)[2, 2].class.should_not be(Date)
  end

  it 'parses default values' do
    spreadsheet.worksheet(0)[2, 1].should == 100
  end

  it 'sets column width based on th width' do
    spreadsheet.worksheet(1).column(0).width.should == 25
  end

  it 'sets column width based on td width' do
    spreadsheet.worksheet(1).column(1).width.should == 35
  end

  # This is for final manual test
  # The test spreadsheet will be saved to /tmp/spreadsheet.xls
  it 'writes to disk' do
    f = File.open('/tmp/spreadsheet.xls', 'wb')
    Spreadsheet.writer(f).write_workbook(spreadsheet, f)
    f.close
  end

end

TEST_HAML = <<-HAML

%table
  %caption A worksheet
  %thead
    %tr
      %th Name
      %th Age
      %th Date
  %tbody
    %tr
      %td Gleb
      %td.num 20
      %td.date 27/05/1991
    %tr
      %td John
      %td.num{ data: { default: 100 } }
      %td.date

%table
  %caption Another worksheet
  %thead
    %tr
      %th{ width: 25 } Name
      %th Age
      %th Date
  %tbody
    %tr
      %td Alice
      %td.float{ width: 35 } 19.5
      %td.date 10/05/1991

HAML