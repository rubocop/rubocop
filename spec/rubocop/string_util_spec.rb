# frozen_string_literal: true

module RuboCop
  module StringUtil
    describe Jaro do
      {
        %w(foo foo)       => 1.000,
        %w(foo bar)       => 0.000,
        %w(martha marhta) => 0.944,
        %w(dwayne duane)  => 0.822
      }.each do |strings, expected|
        context "with #{strings.first.inspect} and #{strings.last.inspect}" do
          subject(:distance) { Jaro.distance(*strings) }

          it "returns #{expected}" do
            expect(distance).to be_within(0.001).of(expected)
          end
        end
      end
    end

    describe JaroWinkler do
      # These samples are derived from Apache Lucene project.
      # https://github.com/apache/lucene-solr/blob/lucene_solr_4_9_0/lucene/suggest/src/test/org/apache/lucene/search/spell/TestJaroWinklerDistance.java
      {
        %w(al al)             => 1.000,
        %w(martha marhta)     => 0.961,
        %w(jones johnson)     => 0.832,
        %w(abcvwxyz cabvwxyz) => 0.958,
        %w(dwayne duane)      => 0.840,
        %w(dixon dicksonx)    => 0.813,
        %w(fvie ten)          => 0.000
      }.each do |strings, expected|
        context "with #{strings.first.inspect} and #{strings.last.inspect}" do
          subject(:distance) { JaroWinkler.distance(*strings) }

          it "returns #{expected}" do
            expect(distance).to be_within(0.001).of(expected)
          end
        end
      end
    end
  end
end
