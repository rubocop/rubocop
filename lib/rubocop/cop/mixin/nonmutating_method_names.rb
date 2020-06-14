# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    # This module provides a list of constants containing nonmutable method names
    # for several core classes.
    module NonmutatingMethodNames
      NONMUTATING_BINARY_OPERATORS = %i[* / % + - == === != < > <= >= <=>].to_set.freeze
      NONMUTATING_UNARY_OPERATORS = %i[+@ -@ ~ !].to_set.freeze
      NONMUTATING_OPERATORS = (NONMUTATING_BINARY_OPERATORS + NONMUTATING_UNARY_OPERATORS).freeze

      NONMUTATING_ARRAY_METHODS = %i[
        all? any? assoc at
        bsearch bsearch_index collect combination
        compact count cycle deconstruct difference dig
        drop drop_while each each_index empty? eql?
        fetch filter find_index first flatten hash
        include? index inspect intersection join
        last length map max min minmax none? one? pack
        permutation product rassoc reject
        repeated_combination repeated_permutation reverse
        reverse_each rindex rotate sample select shuffle
        size slice sort sum take take_while
        to_a to_ary to_h to_s transpose union uniq
        values_at zip |
      ].to_set.freeze

      NONMUTATING_HASH_METHODS = %i[
        any? assoc compact dig
        each each_key each_pair each_value empty?
        eql? fetch fetch_values filter flatten has_key?
        has_value? hash include? inspect invert key key?
        keys? length member? merge rassoc rehash reject
        select size slice to_a to_h to_hash to_proc to_s
        transform_keys transform_values value? values
        values_at
      ].to_set.freeze

      NONMUTATING_STRING_METHODS = %i[
        ascii_only? b bytes bytesize byteslice capitalize
        casecmp casecmp? center chars chomp chop chr codepoints
        count crypt delete delete_prefix delete_suffix
        downcase dump each_byte each_char each_codepoint
        each_grapheme_cluster each_line empty? encode encoding
        end_with? eql? getbyte grapheme_clusters gsub hash
        hex include index inspect intern length lines ljust lstrip
        match match? next oct ord partition reverse rindex rjust
        rpartition rstrip scan scrub size slice squeeze start_with?
        strip sub succ sum swapcase to_a to_c to_f to_i to_r to_s
        to_str to_sym tr tr_s unicode_normalize unicode_normalized?
        unpack unpack1 upcase upto valid_encoding?
      ].to_set.freeze
    end
  end
end
