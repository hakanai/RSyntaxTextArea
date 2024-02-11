/*
 * 02/15/2015
 *
 * AppleScriptTokenMaker.java - Scanner for AppleScript
 * 
 * This library is distributed under a modified BSD license.  See the included
 * RSyntaxTextArea.License.txt file for details.
 */
package org.fife.ui.rsyntaxtextarea.modes;

import java.io.*;
import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.*;


/**
 * Scanner for AppleScript.
 *
 * This implementation was created using
 * <a href="http://www.jflex.de/">JFlex</a> 1.4.1; however, the generated file
 * was modified for performance.  Memory allocation needs to be almost
 * completely removed to be competitive with the handwritten lexers (subclasses
 * of <code>AbstractTokenMaker</code>, so this class has been modified so that
 * Strings are never allocated (via yytext()), and the scanner never has to
 * worry about refilling its buffer (needlessly copying chars around).
 * We can achieve this because RText always scans exactly 1 line of tokens at a
 * time, and hands the scanner this line as an array of characters (a Segment
 * really).  Since tokens contain pointers to char arrays instead of Strings
 * holding their contents, there is no need for allocating new memory for
 * Strings.<p>
 *
 * The actual algorithm generated for scanning has, of course, not been
 * modified.<p>
 *
 * If you wish to regenerate this file yourself, keep in mind the following:
 * <ul>
 *   <li>The generated AppleScriptTokenMaker.java</code> file will contain two
 *       definitions of both <code>zzRefill</code> and <code>yyreset</code>.
 *       You should hand-delete the second of each definition (the ones
 *       generated by the lexer), as these generated methods modify the input
 *       buffer, which we'll never have to do.</li>
 *   <li>You should also change the declaration/definition of zzBuffer to NOT
 *       be initialized.  This is a needless memory allocation for us since we
 *       will be pointing the array somewhere else anyway.</li>
 *   <li>You should NOT call <code>yylex()</code> on the generated scanner
 *       directly; rather, you should use <code>getTokenList</code> as you would
 *       with any other <code>TokenMaker</code> instance.</li>
 * </ul>
 *
 * TODO: Version/Author?
 */
%%

%public
%class AppleScriptTokenMaker
%extends AbstractJFlexTokenMaker
%unicode
%ignorecase
%type org.fife.ui.rsyntaxtextarea.Token


%{


	/**
	 * Constructor.  This must be here because JFlex does not generate a
	 * no-parameter constructor.
	 */
	public AppleScriptTokenMaker() {
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 * @see #addToken(int, int, int)
	 */
	private void addHyperlinkToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer, start,end, tokenType, so, true);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int tokenType) {
		addToken(zzStartRead, zzMarkedPos-1, tokenType);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 * @see #addHyperlinkToken(int, int, int)
	 */
	private void addToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer, start,end, tokenType, so, false);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param array The character array.
	 * @param start The starting offset in the array.
	 * @param end The ending offset in the array.
	 * @param tokenType The token's type.
	 * @param startOffset The offset in the document at which this token
	 *                    occurs.
	 * @param hyperlink Whether this token is a hyperlink.
	 */
	@Override
	public void addToken(char[] array, int start, int end, int tokenType,
						int startOffset, boolean hyperlink) {
		super.addToken(array, start,end, tokenType, startOffset, hyperlink);
		zzStartRead = zzMarkedPos;
	}


	/**
	 * {@inheritDoc}
	 */
	@Override
	public String[] getLineCommentStartAndEnd(int languageIndex) {
		return new String[] { "'", null };
	}


	/**
	 * Returns the first token in the linked list of tokens generated
	 * from <code>text</code>.  This method must be implemented by
	 * subclasses so they can correctly implement syntax highlighting.
	 *
	 * @param text The text from which to get tokens.
	 * @param initialTokenType The token type we should start with.
	 * @param startOffset The offset into the document at which
	 *        <code>text</code> starts.
	 * @return The first <code>Token</code> in a linked list representing
	 *         the syntax highlighted text.
	 */
	public Token getTokenList(Segment text, int initialTokenType, int startOffset) {

		resetTokenList();
		this.offsetShift = -text.offset + startOffset;

		// Start off in the proper state.
		int state;
		switch (initialTokenType) {
			case Token.COMMENT_MULTILINE:
				state = BLOCK_COMMENT;
				start = text.offset;
				break;
			default:
				state = YYINITIAL;
		}

		s = text;
		try {
			yyreset(zzReader);
			yybegin(state);
			return yylex();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return new TokenImpl();
		}

	}


	/**
	 * Refills the input buffer.
	 *
	 * @return      <code>true</code> if EOF was reached, otherwise
	 *              <code>false</code>.
	 */
	private boolean zzRefill() {
		return zzCurrentPos>=s.offset+s.count;
	}


	/**
	 * Resets the scanner to read from a new input stream.
	 * Does not close the old reader.
	 *
	 * All internal variables are reset, the old input stream 
	 * <b>cannot</b> be reused (internal buffer is discarded and lost).
	 * Lexical state is set to <tt>YY_INITIAL</tt>.
	 *
	 * @param reader   the new input stream 
	 */
	public final void yyreset(java.io.Reader reader) {
		// 's' has been updated.
		zzBuffer = s.array;
		/*
		 * We replaced the line below with the two below it because zzRefill
		 * no longer "refills" the buffer (since the way we do it, it's always
		 * "full" the first time through, since it points to the segment's
		 * array).  So, we assign zzEndRead here.
		 */
		//zzStartRead = zzEndRead = s.offset;
		zzStartRead = s.offset;
		zzEndRead = zzStartRead + s.count - 1;
		zzCurrentPos = zzMarkedPos = zzPushbackPos = s.offset;
		zzLexicalState = YYINITIAL;
		zzReader = reader;
		zzAtBOL  = true;
		zzAtEOF  = false;
	}


%}

Letter						= [A-Za-z]
NonzeroDigit				= [1-9]
Digit						= (0|{NonzeroDigit})
HexDigit					= ({Digit}|[A-Fa-f])
/*
NonSeparator				= ([^\t\f\r\n\ \(\)\{\}\[\]\;\,\.\=\>\<\!\~\?\:\+\-\*\/\&\|\^\%\"\']|"#"|"\\")
*/
IdentifierStart				= {Letter}
IdentifierPart				= ({Letter}|{Digit}|_)

/* Docs say \r is whitespace too but other token makers didn't seem to have that */
LineTerminator				= (\n)
WhiteSpace					= ([ \t])
LineContinuation			= (\u00AC)

UnclosedStringLiteral		= ([\"][^\"]*)	/* TODO: Doesn't handle escaped quotes  \"  */
StringLiteral				= ({UnclosedStringLiteral}[\"])

LineCommentBegin			= ("--"|"#")
BlockCommentBegin			= ("(*")
BlockCommentEnd				= ("*)")

IntegerLiteral				= ([+-]?{Digit}+)
FloatExponent				= ([eE][+-]{Digit})
FloatLiteral1				= ({Digit}+)
FloatLiteral2				= ({Digit}+"."{Digit}+)
FloatLiteral3				= ("."{Digit}+)
FloatLiteral				= (({FloatLiteral1}|{FloatLiteral2}|{FloatLiteral3}){FloatExponent}?)
/*
ErrorNumberFormat			= (({IntegerLiteral}|{HexLiteral}|{FloatLiteral}){NonSeparator}+)
*/
BooleanLiteral				= ("true"|"false")

Separator					= ([\{\}])	/* list, record braces */
Separator2					= ([\:])	/* record key-value separator */

Equals						= ("="|("is equal"" to"?)|"equal to"|"equals")
NotEquals					= ("\u2260"|("is not"" equal"?" to"?)|("isn't"" equal"?" to"?)|"doesn't equal"|"does not equal")
GreaterThan					= (">"|"greater than"|"comes after"|"is greater than"|("is not less than or equal"" to?")|("isn't less than or equal"" to?"))
LessThan					= ("<"|"less than"|"is less than"|"comes before"|("is not greater than or equal"" to?")|("isn't greater than or equal"" to?"))
GreaterThanOrEqual			= ("\u2265"|">="|("greater than or equal"" to"?)|("is greater than or equal"" to"?)|"is not less than"|"isn't less than"|"does not come before"|"doesn't come before")
LessThanOrEqual				= ("\u2264"|"<="|("less than or equal"" to"?)|("is less than or equal"" to"?)|"is not greater than"|"isn't greater than"|"does not come after"|"doesn't come after")
StartsWith					= (("start""s"?" with")|("begin""s"?" with"))
EndsWith					= ("end""s"?" with")
Contains					= ("contain""s"?)
DoesNotContain				= ("does not contain"|"doesn't contain")
IsContainedBy				= ("is in"|"is contained by")
IsNotContainedBy			= ("is not in"|"is not contained by"|"isn't contained by")
ReferenceTo					= ((("ref"" to"?)|"reference to")|("a "(("ref"" to"?)|"reference to")))
ComparisonOperator			= ({Equals}|{NotEquals}|{GreaterThan}|{LessThan}|{GreaterThanOrEqual}|{LessThanOrEqual})
ContainmentOperator			= ({StartsWith}|{EndsWith}|{Contains}|{DoesNotContain}|{IsContainedBy}|{IsNotContainedBy})
LogicalOperator				= ("and"|"or"|"not")
MathOperator				= ("*"|"+"|"-"|"/"|"\u00F7"|"div"|"mod"|"^")
Operator					= ("&"|"as"|{ComparisonOperator}|{ContainmentOperator}|{MathOperator}|{ReferenceTo})

UnclosedQuotedIdentifier	= ([\|][^\|]*)
QuotedIdentifier			= ({UnclosedQuotedIdentifier}[\|])
Identifier					= (({IdentifierStart}{IdentifierPart}*)|{QuotedIdentifier})
/*
ErrorIdentifier				= ({NonSeparator}+)
*/

UnclosedRawCode				= ([\u00AB\u300A][^\u00BB|\u300B]*)
RawCode						= ({UnclosedRawCode}[\u00BB|\u300B])

URLGenDelim					= ([:\/\?#\[\]@])
URLSubDelim					= ([\!\$&'\(\)\*\+,;=])
URLUnreserved				= ({Letter}|"_"|{Digit}|[\-\.\~])
URLCharacter				= ({URLGenDelim}|{URLSubDelim}|{URLUnreserved}|[%])
URLCharacters				= ({URLCharacter}*)
URLEndCharacter				= ([\/\$]|{Letter}|{Digit})
URL							= (((https?|f(tp|ile))"://"|"www.")({URLCharacters}{URLEndCharacter})?)

%state EOL_COMMENT
%state BLOCK_COMMENT

%%

<YYINITIAL> {

	/* TODO: Everything is case-insensitive. Does that mess with the keywords and operators? */

	/* Keywords */
	"about" |
	"above" |
	"after" |
	"against" |
	"and" |
	"apart from" |
	"around" |
	"as" |
	"aside from" |
	"at" |
	"back" |
	"before" |
	"beginning" |
	"behind" |
	"below" |
	"beneath" |
	"beside" |
	"between" |
	"but" |
	"by" |
	"considering" |
	"contain" |
	"contains" |
	"continue" |
	"copy" |
	"div" |
	"does" |
	"eighth" |
	"else" |
	"end" |
	"equal" |
	"equals" |
	"error" |
	"every" |
	"exit" |
	"fifth" |
	"first" |
	"for" |
	"fourth" |
	"from" |
	"front" |
	"get" |
	"given" |
	"global" |
	"if" |
	"ignoring" |
	"in" |
	"instead of" |
	"into" |
	"is" |
	"it" |
	"its" |
	"last" |
	"local" |
	"me" |
	"middle" |
	"mod" |
	"my" |
	"ninth" |
	"not" |
	"of" |
	"on" |
	"onto" |
	"or" |
	"out of" |
	"over" |
	"prop" |
	"property" |
	"put" |
	"ref" |
	"reference" |
	"repeat" |
	"returning" |
	"script" |
	"second" |
	"set" |
	"seventh" |
	"since" |
	"sixth" |
	"some" |
	"tell" |
	"tenth" |
	"that" |
	"the" |
	"then" |
	"third" |
	"through" |
	"thru" |
	"timeout" |
	"times" |
	"to" |
	"transaction" |
	"try" |
	"until" |
	"use" |
	"where" |
	"while" |
	"whose" |
	"with" |
	"without"					{ addToken(Token.RESERVED_WORD); }
	"return"					{ addToken(Token.RESERVED_WORD_2); }

	{BooleanLiteral}			{ addToken(Token.LITERAL_BOOLEAN); }

	{LineTerminator}			{ addNullToken(); return firstToken; }

	{Identifier}				{ addToken(Token.IDENTIFIER); }

	{WhiteSpace}+				{ addToken(Token.WHITESPACE); }

	{StringLiteral}				{ addToken(Token.LITERAL_STRING_DOUBLE_QUOTE); }
	{UnclosedStringLiteral}		{ addToken(Token.ERROR_STRING_DOUBLE); addNullToken(); return firstToken; }

	/* TODO: RawCode, UnclosedRawCode */

	{BlockCommentBegin}			{ start = zzMarkedPos-2; yybegin(BLOCK_COMMENT); }
	{LineCommentBegin}			{ start = zzMarkedPos-2; yybegin(EOL_COMMENT); }

	{Separator}					{ addToken(Token.SEPARATOR); }
	{Separator2}				{ addToken(Token.IDENTIFIER); }
	{Operator}					{ addToken(Token.OPERATOR); }

	{IntegerLiteral}			{ addToken(Token.LITERAL_NUMBER_DECIMAL_INT); }
	{FloatLiteral}				{ addToken(Token.LITERAL_NUMBER_FLOAT); }

	/* TODO: Errors
	{ErrorNumberFormat}			{ addToken(Token.ERROR_NUMBER_FORMAT); }
	{ErrorIdentifier}			{ addToken(Token.ERROR_IDENTIFIER); }
	*/

	/* Ended with a line not in a string or comment. */
	<<EOF>>						{ addNullToken(); return firstToken; }

	/* Catch any other (unhandled) characters. */
	.							{ addToken(Token.IDENTIFIER); }

}


<EOL_COMMENT> {
	[^hwf\n]+				{}
	{URL}					{ int temp=zzStartRead; addToken(start, zzStartRead-1, Token.COMMENT_EOL); addHyperlinkToken(temp, zzMarkedPos-1, Token.COMMENT_EOL); start = zzMarkedPos; }
	[hwf]					{}
	\n						{ addToken(start, zzStartRead-1, Token.COMMENT_EOL); addNullToken(); return firstToken; }
	<<EOF>>					{ addToken(start, zzStartRead-1, Token.COMMENT_EOL); addNullToken(); return firstToken; }
}

/* TODO: AppleScript also supports nesting block comments and JFlex seems limiting in this regard. */
<BLOCK_COMMENT> {
	[^hwf\n\*]+				{}
	{URL}					{ int temp=zzStartRead; addToken(start, zzStartRead-1, Token.COMMENT_MULTILINE); addHyperlinkToken(temp, zzMarkedPos-1, Token.COMMENT_MULTILINE); start = zzMarkedPos; }
	[hwf]					{}
	\n						{ addToken(start, zzStartRead-1, Token.COMMENT_MULTILINE); return firstToken; }
	{BlockCommentEnd}		{ yybegin(YYINITIAL); addToken(start, zzStartRead+1, Token.COMMENT_MULTILINE); }
	\*						{}
	<<EOF>>					{ addToken(start, zzStartRead-1, Token.COMMENT_MULTILINE); return firstToken; }
}
