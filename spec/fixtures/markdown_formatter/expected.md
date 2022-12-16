# RuboCop Inspection Report

4 files inspected, 23 offenses detected:

### app/controllers/application_controller.rb - (2 offenses)
  * **Line # 1 - convention:** Style/Documentation: Missing top-level documentation comment for `class ApplicationController`.

    ```rb
    class ApplicationController < ActionController::Base
    ```

  * **Line # 1 - convention:** Style/FrozenStringLiteralComment: Missing frozen string literal comment.

    ```rb
    class ApplicationController < ActionController::Base
    ```

### app/controllers/books_controller.rb - (14 offenses)
  * **Line # 1 - convention:** Style/Documentation: Missing top-level documentation comment for `class BooksController`.

    ```rb
    class BooksController < ApplicationController
    ```

  * **Line # 1 - convention:** Style/FrozenStringLiteralComment: Missing frozen string literal comment.

    ```rb
    class BooksController < ApplicationController
    ```

  * **Line # 2 - convention:** Style/SymbolArray: Use `%i` or `%I` for an array of symbols.

    ```rb
      before_action :set_book, only: [:show, :edit, :update, :destroy]
    ```

  * **Line # 12 - convention:** Style/EmptyMethod: Put empty method definitions on a single line.

    ```rb
      def show ...
    ```

  * **Line # 21 - convention:** Style/EmptyMethod: Put empty method definitions on a single line.

    ```rb
      def edit ...
    ```

  * **Line # 31 - convention:** Layout/LineLength: Line is too long. [121/120]

    ```rb
            format.html { redirect_to @book, notice: 'Book was successfully created.' } # aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    ```

  * **Line # 45 - convention:** Layout/LineLength: Line is too long. [121/120]

    ```rb
            format.html { redirect_to @book, notice: 'Book was successfully updated.' } # aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    ```

  * **Line # 59 - convention:** Layout/LineLength: Line is too long. [121/120]

    ```rb
          format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' } # aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    ```

  * **Line # 64 - convention:** Layout/EmptyLinesAroundAccessModifier: Keep a blank line before and after `private`.

    ```rb
      private
    ```

  * **Line # 66 - convention:** Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.

    ```rb
        def set_book
    ```

  * **Line # 66 - convention:** Layout/IndentationConsistency: Inconsistent indentation detected.

    ```rb
        def set_book ...
    ```

  * **Line # 70 - convention:** Layout/LineLength: Line is too long. [121/120]

    ```rb
        # Never trust parameters from the scary internet, only allow the allow list through. aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    ```

  * **Line # 71 - convention:** Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.

    ```rb
        def book_params
    ```

  * **Line # 71 - convention:** Layout/IndentationConsistency: Inconsistent indentation detected.

    ```rb
        def book_params ...
    ```

### app/models/book.rb - (7 offenses)
  * **Line # 1 - convention:** Style/Documentation: Missing top-level documentation comment for `class Book`.

    ```rb
    class Book < ActiveRecord::Base
    ```

  * **Line # 1 - convention:** Style/FrozenStringLiteralComment: Missing frozen string literal comment.

    ```rb
    class Book < ActiveRecord::Base
    ```

  * **Line # 2 - convention:** Naming/MethodName: Use snake_case for method names.

    ```rb
      def someMethod
    ```

  * **Line # 3 - warning:** Lint/UselessAssignment: Useless assignment to variable - `foo`.

    ```rb
        foo = bar = baz
    ```

  * **Line # 3 - warning:** Lint/UselessAssignment: Useless assignment to variable - `bar`. Did you mean `baz`?

    ```rb
        foo = bar = baz
    ```

  * **Line # 4 - convention:** Style/RescueModifier: Avoid using `rescue` in its modifier form.

    ```rb
        Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(full_document)[1] rescue full_document
    ```

  * **Line # 4 - convention:** Style/RegexpLiteral: Use `%r` around regular expression.

    ```rb
        Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(full_document)[1] rescue full_document
    ```

