" Vim indent file
" Language:		JavaScript
" Author: 		Preston Koprivica (pkopriv2@gmail.com)	
" URL:
" Last Change: 	April 30, 2010

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetJsIndent(v:lnum)
setlocal indentkeys=0{,0},0),:,!^F,o,O,e,*<Return>,=*/

" Clean CR when the file is in Unix format
if &fileformat == "unix" 
    silent! %s/\r$//g
endif

" Simple Objects
let s:js_object_beg = '[{\[]\s*\(//.*\)*$'
let s:js_object_end = '^[^()\[\]{}]*\(}\|\]\|})\|})(.*)\|\])\)\s*[;,]\=\s*\(//.*\)*$'

" Simple control blocks (those not beginngin with "{")
let s:js_s_cntrl_beg = '\(\(\(if\|for\|with\)\s*(.*)\)\|try\)\s*\(//.*\)*$' 		
let s:js_s_cntrl_mid = '\(\(\(else\s*if\|catch\)\s*(.*)\)\|\(finally\|else\)\)\s*\(//.*\)*\s*$'

" Multi line control blocks (those beginning with "{")
let s:js_m_cntrl_beg = s:js_object_beg " Same as js_object_beg
let s:js_m_cntrl_mid = '}.*{\s*\(//.*\)*$'

" Multi line declarations
let s:js_cont_beg = '([^()]*\s*\(//.*\)*$'
let s:js_s_cont_end = '^[^()]*)\s*\(//.*\)*$'
let s:js_m_cont_end = '^[^()]*)\s*{\s*\(//.*\)*$'

" Special switch control
let s:js_switch_mid = '\(case.*\|default\)\s*:'

" Single line comment (// xxx)
let s:js_comment = '^\s*//.*'

" Javadoc style comments
let s:js_javadoc_comment_beg = '^\s*/\*\**.*'
let s:js_javadoc_comment_mid = '^\s*\*[^/]*'
let s:js_javadoc_comment_end = '^\s*\*/\s*$'

" Block Comments (/* */) (TODO: ADD SUPPORT FOR THESE)
let s:js_block_comment_beg = ''
let s:js_block_comment_end = ''

" Grabs the nearest non-commented line
function! GetNonCommentLine(lnum)
	let lnum = prevnonblank(a:lnum)

	" Do not go past the beginning 
	if lnum == 0 
		return 0
	endif
	
	" If the 
	if IsComment(lnum) 
		return GetNonCommentLine(lnum-1)
	else
		return lnum
	endif
endfunction

" Determines whether a line is a comment or not.
function! IsComment(lnum)
	let line = getline(a:lnum)

	return line =~ s:js_javadoc_comment_beg ||
				\ line =~ s:js_javadoc_comment_mid || 
				\ line =~ s:js_javadoc_comment_end || 
				\ line =~ s:js_comment
endfunction

function! GetJsIndent(lnum)
    " Grab the first non-comment line prior to this line
    let pnum = GetNonCommentLine(a:lnum-1)
    
    " First line, start at indent = 0
    if pnum == 0
	    echo "No, noncomment lines prior to: " . a:lnum
	    return 0
    endif

    " Grab the second non-comment line prior to this line
    let ppnum = GetNonCommentLine(pnum-1)

    echo "Line: " . a:lnum
    echo "PLine: " . pnum
    echo "PPLine: " . ppnum

    " Grab the lines themselves.
    let line = getline(a:lnum)
    let pline = getline(pnum)
    let ppline = getline(ppnum)

    " Determine the current level of indentation
    let ind = indent(pnum)

    " Cases for indenting: 
    "  1.) If current line immediately follows an object beginning
    "  2.) If current line immediately follows a control structure beginning
    "      and is not itslef an object beginning
    "  3.) If current line immediately follows a control structure middle
    "      and is not itself an object beginning
    "
    "
    " Cases for unindenting
    "  1.) If current line is an object ending
    "  2.) If current line is a control structure middle
    "  3.) If current line is TWO lines following a control structure
    "      beginning WITHOUT an opening bracket
    "  4.) If current line is TWO lines following a control structure
    "      middle WITHOUT an opening bracket
    "
    " ALL OTHER CASES...DO NOTHING!
    "
    if pline =~ s:js_cont_beg
	    echo "PLine matched continuation beginning"
	return ind + &sw
    endif

    if pline =~ s:js_s_cont_end
	    echo "Pline matched simple continuation end"
	if line =~ s:js_object_beg
		echo "Line matched object beginning"
		return ind - &sw
	else
		return ind
	endif
    endif

    if pline =~ s:js_m_cont_end
	    echo "Pline matched multi-line continuation end"
	    if line =~ s:js_object_end
		    echo "Pline matched object end"
		    return ind - &sw
	    else
		    return ind 
	    endif
    endif

    " Handle: Previous line is 
    if pline =~ s:js_object_beg ||
			    \ pline =~ s:js_m_cntrl_beg ||
			    \ pline =~ s:js_m_cntrl_mid ||
			    \ pline =~ s:js_switch_mid 
	    echo "PLine matches object beginning pattern"


	    if line =~ s:js_object_end || 
				    \ line =~ s:js_m_cntrl_mid ||
				    \ line =~ s:js_switch_mid 
		    		
		    echo "Line matches object end or mid control"
		    return ind
	    else
		    echo "Line doesn't match object end"
		    return ind + &sw
	    endif
    endif

    if pline =~ s:js_s_cntrl_beg ||
			    \ pline =~ s:js_s_cntrl_mid 
	    echo "PLine matches simple control beginning or mid"
	    
	    if line =~ s:js_s_cntrl_mid ||
				    \ line =~ s:js_object_beg
		    echo "Line matches simple control mid"
		    return ind
	    else 
		    echo "Line doesn't match simple control mid"
		    return ind + &sw
	    endif

    endif

    if pline =~ s:js_object_end
	    echo "PLine matches object end"

	    if line =~ s:js_s_cntrl_mid
		    echo "Lines matches simple control mid"
		    return ind
	    endif
    endif


    if line =~ s:js_object_end || 
			    \ line =~ s:js_m_cntrl_mid ||
			    \ line =~ s:js_switch_mid 
	    echo "Line matches object end, multiple control mid, or switch control mid"

	    return ind - &sw
    endif


    if ppline =~ s:js_s_cntrl_beg || ppline =~ s:js_s_cntrl_mid
	    echo "PPLine matches a simple control"
	    return ind - &sw
    endif

    echo "Indenting to: " . ind
    return ind
endfunction
