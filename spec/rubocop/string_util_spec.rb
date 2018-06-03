# frozen_string_literal: true

RSpec.describe RuboCop::StringUtil do
  {
    # These samples are derived from Apache Lucene project.
    # https://github.com/apache/lucene-solr/blob/LUCENE-6989-v2/lucene/suggest/src/test/org/apache/lucene/search/spell/TestJaroWinklerDistance.java
    %w[al al]             => 1.000,
    %w[martha marhta]     => 0.961,
    %w[jones johnson]     => 0.832,
    %w[abcvwxyz cabvwxyz] => 0.958,
    %w[dwayne duane]      => 0.840,
    %w[dixon dicksonx]    => 0.813,
    %w[fvie ten]          => 0.000,
    # These are from Rich Milne.
    # https://github.com/richmilne/JaroWinkler/blob/master/jaro/jaro_tests.py
    %w[SHACKLEFORD SHACKELFORD] => 0.98182,
    %w[DUNNINGHAM CUNNIGHAM]    => 0.89630,
    %w[NICHLESON NICHULSON]     => 0.95556,
    %w[MASSEY MASSIE]           => 0.93333,
    %w[ABROMS ABRAMS]           => 0.92222,
    %w[HARDIN MARTINEZ]         => 0.72222,
    %w[ITMAN SMITH]             => 0.46667,
    %w[JERALDINE GERALDINE]     => 0.92593,
    %w[MICHELLE MICHAEL]        => 0.92143,
    %w[JULIES JULIUS]           => 0.93333,
    %w[TANYA TONYA]             => 0.88000,
    %w[SEAN SUSAN]              => 0.80500,
    %w[JON JOHN]                => 0.93333,
    %w[JON JAN]                 => 0.80000,
    %w[DWAYNE DYUANE]           => 0.84000,
    %w[CRATE TRACE]             => 0.73333,
    %w[WIBBELLY WOBRELBLY]      => 0.85298,
    %w[MARHTA MARTHA]           => 0.96111,
    %w[aaaaaabc aaaaaabd]       => 0.95000,
    %w[ABCAWXYZ BCAWXYZ]        => 0.91071,
    %w[ABCVWXYZ CBAWXYZ]        => 0.91071,
    %w[ABCDUVWXYZ DABCUVWXYZ]   => 0.93333,
    %w[ABCDUVWXYZ DBCAUVWXYZ]   => 0.96667,
    %w[ABBBUVWXYZ BBBAUVWXYZ]   => 0.96667,
    %w[ABCDUV11lLZ DBCAUVWXYZ]  => 0.73117,
    %w[ABBBUVWXYZ BBB11L3VWXZ]  => 0.77879,
    %w[A A]                     => 1.00000,
    %w[AB AB]                   => 1.00000,
    %w[ABC ABC]                 => 1.00000,
    %w[ABCD ABCD]               => 1.00000,
    %w[ABCDE ABCDE]             => 1.00000,
    %w[AA AA]                   => 1.00000,
    %w[AAA AAA]                 => 1.00000,
    %w[AAAA AAAA]               => 1.00000,
    %w[AAAAA AAAAA]             => 1.00000,
    %w[A B]                     => 0.00000
  }.each do |strings, expected|
    context "with #{strings.first.inspect} and #{strings.last.inspect}" do
      subject(:distance) { described_class.similarity(*strings) }

      it "returns #{expected}" do
        expect(distance).to be_within(0.001).of(expected)
      end
    end
  end
end
