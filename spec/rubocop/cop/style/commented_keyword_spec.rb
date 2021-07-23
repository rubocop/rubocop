# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CommentedKeyword, :config do
  it 'registers an offense and corrects when commenting on the same line as `end`' do
    expect_offense(<<~RUBY)
      if x
        y
      end # comment
          ^^^^^^^^^ Do not place comments on the same line as the `end` keyword.
    RUBY

    expect_correction(<<~RUBY)
      if x
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `begin`' do
    expect_offense(<<~RUBY)
      begin # comment
            ^^^^^^^^^ Do not place comments on the same line as the `begin` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      begin
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `class`' do
    expect_offense(<<~RUBY)
      class X # comment
              ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      class X
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `module`' do
    expect_offense(<<~RUBY)
      module X # comment
               ^^^^^^^^^ Do not place comments on the same line as the `module` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      module X
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `def`' do
    expect_offense(<<~RUBY)
      def x # comment
            ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      def x
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on indented keywords' do
    expect_offense(<<~RUBY)
      module X
        class Y # comment
                ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
          z
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module X
      # comment
        class Y
          z
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting after keyword with spaces' do
    expect_offense(<<~RUBY)
      def x(a, b) # comment
                  ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      def x(a, b)
        y
      end
    RUBY
  end

  it 'registers an offense and corrects for one-line cases' do
    expect_offense(<<~RUBY)
      def x; end # comment
                 ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
    RUBY

    expect_correction(<<~RUBY)
      # comment
      def x; end
    RUBY
  end

  it 'does not register an offense if there are no comments after keywords' do
    expect_no_offenses(<<~RUBY)
      if x
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      class X
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      begin
        x
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      module X
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      # module Y # trap comment
    RUBY
    expect_no_offenses(<<~RUBY)
      'end' # comment
    RUBY
    expect_no_offenses(<<~RUBY)
      <<-HEREDOC
        def # not a comment
      HEREDOC
    RUBY
  end

  it 'does not register an offense for certain comments' do
    expect_no_offenses(<<~RUBY)
      class X # :nodoc:
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      class X
        def y # :yields:
          yield
        end
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x # rubocop:disable Metrics/MethodLength
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x # rubocop:todo Metrics/MethodLength
        y
      end
    RUBY
  end

  it 'does not register an offense if AST contains # symbol' do
    expect_no_offenses(<<~RUBY)
      def x(y = "#value")
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x(y: "#value")
        y
      end
    RUBY
  end

  it 'accepts keyword letter sequences that are not keywords' do
    expect_no_offenses(<<~RUBY)
      options = {
        end_buttons: true, # comment
      }
    RUBY
    expect_no_offenses(<<~RUBY)
      defined?(SomeModule).should be_nil # comment
    RUBY
    expect_no_offenses(<<~RUBY)
      foo = beginning_statement # comment
    RUBY
  end

  it 'checks a long comment in less than one second' do
    Timeout.timeout(1) { expect_no_offenses(<<~RUBY) }
      begin
        # 13c7722bd7b3c830bea3dfbd89d447979b902335c5e517ffdba6ee091d01a1151a6c6d9609f6733a4a12116dd8bb88a0d20d62691ef3dc648393d492f6506e48e6946508783b94463d118113ae98a540a1dcb376b38751f1af8e95ddc70184b2b4d2f8844bf02de8a956b445d9c9fe886dd15c8a2b2e1c7bd2f3cc67b065f5383dca814898b5ead264adea9a88ed5accb31bd5654e2628e5958fe84bc2c79c12a9897d9b4820a81aac5999bc64c7edbbe592a52bf7c583efb9c26de9a11b42166e6fdbc527541278ff3861f0bd0c4a1c5b21d5e1d116b07def9ef8bb8b8b569b364d44edac389e936c8911541896308a9cb8e45e3406750edd35f6f8e804109042808a255f0f8660218e07c4374786ec5c32c9dab56bc0f7354852cf2acf6846bb6323ee7b488f68fb823b51dd819dc630d06569933839fc26acc4f8004387ff15e44090907dad8b5eef3ed8d0cbd3d03d6dfcf85494f67c61e34f055ef8af86c0244a8a6428168cf92e5fe7cd8215165dac197d944fdce3c71f61d0e83d98ea916bc0b8285c64b8590db7907af0bc302995b3669da2e05c13a8a4ce2bfaf431a43d8c0d719d049f012923e027128ab45e0a72d00e92096d4b5414599068ed665d1baf52fb283aeee06d0f67b35d2e4b766d0f0557d6150170fa9a16fe42af914ff696ab701034fde7bd9d944f0c3c3ccc18020ba902d15365bbf0547aea1b364f7e4153e1f45ebf2737672bf109c0d64e9e58780fe26938b2ec33f2520bb6f7c3815ae8f0ae4a73805f9257f4ff2b467bb15b7867d292705e973577f6d65acbcd8ee2461c8287925dacbf9ff785f41be0806e4927f6eca36a16a54bcfe8b70d327ce7e8b73d692cc709b2a5bd8a785eba39aad42d77f0d3d519cd42503c346826beca9bede8f40dfceca84bdc41842853f20546a56841e4db3063a3cfda7d415896fee52713c21475e05c5339caf63fe7d8fde968ca52e6746dc1716b537af7385cab47ea47a83621488587fe36a4c6d9e6ff0a0e96011393daeaa09ac329f3f7926e1a7837642843ef6af6ceab2d1e2d784942c6f4d520a48eb34db0c4097de5bb530ab9282e61f364ee0866176587ed7c52fc401523123873a4c6844b9ff87193465530da4133bdd1a766ab90da03b38066509b51eb2d115e77dd7808afd8ca352e79ded5c6b62bad51149826bf52b532bb5d688e6ff9c846a1e3d54831fdaf20982a901028f6e921c86628dfd71d4da0b88c99a3f46e69c89714b1f0f39168e0f36b260647cbf4d608ae20518c4268d07c251f9f94a473eb92046eae892b9bd06027d4aa4b70e0252703aab8bffa409ac0ca3742bcf7f18f172a79b7b43c7511f3a4e4084ec173be024ec54e130d74de4dde71efdeb5c9507bf652d89b247d2612b78767684497d34636b4a29a2f0cbdd5f10fefd130917d44c8661cb09869a3fc85a390eb43ff9752cd919da24f437f159a43660fa0ba72a100792b2d742aa2bd24c2561a8170c4af67f1314563e75816b8648c9a6c8801dc7913763bba0b3dccc16e7f7365fb181cddd2cfb1e2c12848782e362c255ec209c4b0bf84908354056ac1609492479d3e56fd1956ab8fa523d100a43b1eab397665155acb714da7342eea81855504189e957d61a9ec7194d6a20e62dd5beaa07360443f34de8ed07fd3a387a411e1e6efeeec202ce3635ebbd87641c8ad1ab2e5862712ca230c0cb5aef8ec8ec6d63bedb8a1cc6e5657de15258e5d81c97a4c736d19b81c14b2a1ec3c0d36b5f670877b99288adf5822b851727dea50469f832783c7a23710003f05bbb24e2a175fc23022180b6d4492ec210a5ef4328de969536619161956815d7cbafb9dc29df6c4b3ea733c41db465e5b47c94ed31f922c2cc07d78d208092f452069c54a80248b8f5ef10f8f72a9a575c38fa2d2ab2b150b85fd34913920780750193c4e3680c4569cbc08b08ba94bb50307b63977469e5794049b5fc28125d5cc53fa3f12b77799e2021ccaff08eada38fca5223ef7dfdb4e037b5986b55f406e00cbb401062ae439adf5b244bbc9b08e6bdd2982562422c853ccfd880ae30b4694aec839ffd0e560473064c96855afd38e5d20dedd391a61
      end
    RUBY
  end
end
