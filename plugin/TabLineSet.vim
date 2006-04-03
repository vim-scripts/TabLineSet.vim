" ---------------------------------------------------------------------------
" -          TabLineSet.vim  -- example for tabline configuration    "{{{
"
"
" 
" Author:		Eric Arnold ( eric_p_arnold in_the_vicinity_of yahoo.com )
" Last Change:	Mon Apr 03, 04/03/2006 6:46:59 AM
" Requires:		Vim 7
" Version: 		1.2		Sat Apr 01, 04/01/2006 2:53:43 AM
" Version: 		1.3		Sun Apr 02, 04/02/2006 1:36:01 AM
" 						- Added more indicators, and toggle mapping funcs
" 						  for verbose control.
" 						- Changed the name of the script from tabset.vim
" 						- Solidified the non-GUI color scheme.
"						- Started some hooks to customize slack area.
" Version: 		1.4		Mon Apr 03, 04/03/2006 6:47:11 AM
"						- added comma list of buffers contained in tab
"						- changed toggle and rotate mapping functions to
"						  handle multiple option sets to switch through
"
" Acknowledgements:	The skeleton came from the help pages.
"
" Synopsis:
"
"	-	Configurable, intelligent/dynamic tab field sizing.
"
"	-	New colorscheme and general presentation.
"
"	-	The indicator sets are customizable.
"		(It will also turn verbose mode off automatically, as needed.)
"
"		You can add the   g:TabLineSet_.*   vars to your .vimrc, where you can
"		customize tab min/max, etc., and these these indicators:
"			modified		: whether any window in the tab needs saving
"			windows			: window count in the tab
"			buffers_list	: tab label contains comma list of buffers contained
"			closers			: add hot spots ("!") to the tab for click-to-close
"			These are mostly for development:
"			tabnr			: include the tab number for the selected tab/window
"			winnr			: ... window number
"			bufnr			: ... buffer number
"
"
"		You can add these mappings to your .vimrc to control the verbose
"		settings on the fly:
"			nmap <Leader>tv :call TabLineSet_verbose_toggle()<CR>
"			nmap <Leader>tr :call TabLineSet_verbose_rotate()<CR>
"
"		You can change the option sets it rotates through, via the nested
"		list:   g:TabLineSet_verbose_sets
"
" Issues:
"
" 	-	If it doesn't initialize the highlighting properly upon starting up,
" 		it is probably conflicting with a colorscheme or something.  If you
" 		can't find the conflict, try uncommenting the TabEnter autocommand
" 		near the end of the script.
" }}}

 

if v:version >= 700
else
	echomsg "Vim 7 or higher is required for TabLineSet.vim"
	finish
endif

let g:TabLineSet_min = 4			" minimum tab width (space padded)
let g:TabLineSet_min2 = 4			" ... used for 'buffers_list'
let g:TabLineSet_max = 999			" maximun tab width
let g:TabLineSet_verbose_auto = 7	" turn on/off verbose at this tab width

" Masterlist:
let s:verbose_options = 
	\ [ 
	\	'modified', 'windows', 'buffers_list', 'closers', 
	\	'tabnr', 'winnr', 'bufnr', 'filler_func'
	\ ]

let g:TabLineSet_verbose_sets = 
	\ [
		\ [ 'modified', 'windows', 'buffers_list', 'closers', 'filler_func' ],
		\ [ 'modified', 'windows', 'closers' ],
		\ [ 'buffers_list' ],
		\ [ ],
		\ s:verbose_options
	\ ]


let g:TabLineSet_verbose = join( g:TabLineSet_verbose_sets[0], ',' )


let g:TabLineSetFillerFunc = 'TabLineSetFillerTest'
								" Use the filler func to doddle in the ending
								" space in the tabline.



function! TabLineSet_main()
	
	let verbose = g:TabLineSet_verbose
	let avail = winwidth( winnr() )

	let numtabs = tabpagenr('$')
	" account for space padding between tabs, and the "close" button
	let maxlen = ( &columns - ( numtabs * 3 ) 
				\ - ( verbose == '' ? 2 : 0 ) ) / numtabs
	if maxlen > g:TabLineSet_max
		let maxlen =  g:TabLineSet_max
	endif
	if maxlen < g:TabLineSet_verbose_auto
		let verbose = ''
	endif

	let maxlen_start = maxlen

	" Loop to extend maxlen
	let maxloop = 10
	while ( maxloop > 0 ) && ( avail > 1 ) 
				\ && ( maxlen_start < winwidth( winnr() ) )
		let maxloop = maxloop - 1

		let maxlen = maxlen_start

		let tabline_out = ''
		let tabline_pos = 0
		for tabnum in range( 1, tabpagenr('$') )

			let buflist = []
			let buflist = tabpagebuflist( tabnum )
			if len( buflist ) < 1
				continue
			endif

			let modded = ''
			for bufnum in buflist
				if getbufvar( bufnum,  '&modified' ) != 0
					let modded = '+'
				endif
			endfor

			let is_selected = tabnum == tabpagenr()

			let tabline_out .= is_selected ? '%#TabLineSel#' : '%#TabLine#'

			" set the tab page number (for mouse clicks)
			let tabline_out .= '%' . ( tabnum ) . 'T'


			" Add an indicator that some buffer in the tab is modified:
			let tablabel = ''
			if verbose =~ 'modified' && modded != ''
				let tablabel .= '%#TabModded#' . modded
				let tablabel .= is_selected ? '%#TabLineSel#' : '%#TabLine#'
				let maxlen = maxlen - 1
			endif

			let winnr = tabpagewinnr( tabnum )
			let numwins = tabpagewinnr( tabnum, ("$") )


			" --------------------
			" Misc values, i.e. the number of windows in the tab:
			let numwins_out = ''
			if verbose =~ 'windows'  && len( buflist ) > 1
				let numwins_out = numwins
				let maxlen = maxlen - strlen( numwins_out )
			endif

			let tabnr_out = ''
			if verbose =~ 'tabnr' && is_selected
				let tabnr_out .= 't' . tabnum 
				let maxlen = maxlen - strlen( tabnr_out )
			endif

			let winnr_out = ''
			if verbose =~ 'winnr' && is_selected
				let winnr_out .= 'w' . winnr 
				let maxlen = maxlen - strlen( winnr_out )
			endif

			let bufnr_out = ''
			if verbose =~ 'bufnr' && is_selected
				let bufnr_out .= 'b' . winbufnr( winnr )
				let maxlen = maxlen - strlen( bufnr_out )
			endif


			let out_list = [ numwins_out, tabnr_out, winnr_out, bufnr_out ]
			let out_list = filter( out_list, 'v:val != "" ' )
			if len( out_list ) > 0
				let tablabel .= '(' 
							\ . ( is_selected ? '%#TabWinNumSel#' : '%#TabWinNum#' )
							\ . join( out_list , ',' )
							\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )
							\ . ')'
				let tabline_pos = tabline_pos + 
							\ strlen( '(' . join( out_list , ',' ) . ')' )
			endif
			" end misc values


			" --------------------
			"  Add buffer name(s)
			let winnr_start = 1
			let winnr_stop = numwins
			if verbose !~ 'buffers_list'
				let winnr_start = winnr
				let winnr_stop = winnr
			endif

			" subtract - numwins   to accound for commas:
			let maxlen1 = ( ( maxlen - numwins + 1 ) / numwins )
			if maxlen1 < g:TabLineSet_min2 
				let winnr_start = winnr
				let winnr_stop = winnr
			endif

			let bufname_list = []
			let adj_maxlen = 0
			for winnr1 in range( winnr_start, winnr_stop )
				let tabbufname = bufname( buflist[ winnr1 - 1] )
				let tabbufname = fnamemodify( tabbufname, ':t' )
				if tabbufname == ''
					let tabbufname = '[No Name]'
				endif
				call add( bufname_list, tabbufname )
			endfor

			" shrink the names in the list a bit/byte at a time, so the space
			" is distributed evenly:
			let tabbufnames = join( bufname_list, ',' )
			while strlen( tabbufnames ) > maxlen
				let longest = 0
				let which = 0
				for i in range( 0, len( bufname_list ) - 1 )
					if strlen( bufname_list[ i ] ) > longest
						let which = i
						let longest = strlen( bufname_list[ i ] )
					endif
				endfor
				let b = bufname_list[ which ]
				let bufname_list[ which ] = strpart( b, 0, strlen( b ) - 1 )
				let tabbufnames = join( bufname_list, ',' )
			endwhile

			call map( bufname_list, 'strpart( v:val, 0,  maxlen1 )' )

			let sep = ''
					\ . ( is_selected ? '%#TabWinNumSel#' : '%#TabWinNum#' )
					\ . ','
					\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )

			let tabbufnames = join( bufname_list, ',' )

			" Pad to _min
			let len = strlen( tabbufnames )
			while strlen( tabbufnames ) < g:TabLineSet_min 
						\ && strlen( tabbufnames )< maxlen
				let tabbufnames = tabbufnames . ' '
			endwhile

			"let tabbufnames = strpart( tabbufnames, 0,  maxlen )
			let tabline_pos = tabline_pos + strlen( tabbufnames )

			let sep = ''
					\ . ( is_selected ? '%#TabWinNumSel#' : '%#TabWinNum#' )
					\ . ','
					\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )

			let tabbufnames = join( bufname_list, sep )

			" end bufnames section


			" --------------------
			"  Closers
			let tabexit = ''
			if verbose =~ 'closers'
				let tabexit .= ( is_selected ? '%#TabExitSel#' : '%#TabExit#' )
							\ . '%' . tabnum . 'X!%X'
				let maxlen = maxlen - 1
				let tabline_pos = tabline_pos + 1
			endif


			" --------------------
			"  Put the pieces together
			let tablabel .= ' ' . tabbufnames

			let tabline_out .= tablabel  . ' '

			let tabline_out .= tabexit

			let tabline_out .= '%#TabSep#' . '|'
						\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )

			let tabline_pos = tabline_pos + 3

		endfor


		" after the last tab fill with TabLineFill and reset tab page nr
		let tabline_out .= '%#TabLineFillEnd#%T'


		" right-align the label to close the current tab page
		let last_close = ''
		if tabpagenr('$') > 1 && verbose == ''
			let last_close = '%=%#TabLine#%999X X'
		endif

		let avail = &columns - tabline_pos - ( last_close == '' ? 2 : 0 )

		if g:TabLineSetFillerFunc != '' && verbose =~ 'filler_func'
			let tabline_out .= '%{' . g:TabLineSetFillerFunc . '(' . avail . ')}'
		endif

		let tabline_out .= last_close

		" too slow:
		"let maxlen_start = maxlen_start + 1
	
		let maxlen_start = maxlen_start + ( avail / numtabs )

	endwhile " extend maxlen

	return tabline_out
endfunction





function! TabLineSetFillerNull( avail )
	return ''
endfunction


function! TabLineSetFillerTest( avail )
	let out = strftime( '%H:%M:%S' )
	if strlen( out ) > a:avail
		let out = ''
	else
		while strlen( out ) <= a:avail
			let out = '.'. out
		endwhile
	endif
	return out
endfunction


let s:TabLineSet_verbose_save = ''


function! TabLineSet_verbose_toggle()
	if s:TabLineSet_verbose_save == ''
		let s:TabLineSet_verbose_save = g:TabLineSet_verbose
		let g:TabLineSet_verbose = ''
	else
		let g:TabLineSet_verbose = s:TabLineSet_verbose_save
		let s:TabLineSet_verbose_save = ''
	endif
	" Make it update:
	silent! normal! gtgT
endfunction



let s:verbose_sets_idx = 0

function! TabLineSet_verbose_rotate()
	let s:verbose_sets_idx = s:verbose_sets_idx + 1
	if s:verbose_sets_idx > len( g:TabLineSet_verbose_sets ) - 1
		let s:verbose_sets_idx = 0
	endif

	let g:TabLineSet_verbose = join( 
				\g:TabLineSet_verbose_sets[ s:verbose_sets_idx ], ',' )
	silent! normal! gtgT
endfunction







set tabline=%!TabLineSet_main()

if &showtabline < 1
	set showtabline=1	" 2=always
endif

function! TabLineSet_hl_init()
	"							*cterm-colors*
	"	    NR-16   NR-8    COLOR NAME ~
	"	    0	    0	    Black
	"	    1	    4	    DarkBlue
	"	    2	    2	    DarkGreen
	"	    3	    6	    DarkCyan
	"	    4	    1	    DarkRed
	"	    5	    5	    DarkMagenta
	"	    6	    3	    Brown, DarkYellow
	"	    7	    7	    LightGray, LightGrey, Gray, Grey
	"	    8	    0*	    DarkGray, DarkGrey
	"	    9	    4*	    Blue, LightBlue
	"	    10	    2*	    Green, LightGreen
	"	    11	    6*	    Cyan, LightCyan
	"	    12	    1*	    Red, LightRed
	"	    13	    5*	    Magenta, LightMagenta
	"	    14	    3*	    Yellow, LightYellow
	"	    15	    7*	    White
	"
	"	The number under "NR-16" is used for 16-color terminals ('t_Co'

	hi! TabWinNum term=bold,underline cterm=underline gui=bold,underline
				\ ctermfg=green guifg=Green ctermbg=darkgrey guibg=DarkGrey

	hi! TabWinNumSel term=bold,underline cterm=underline gui=bold,underline
				\ ctermfg=magenta ctermbg=blue guifg=Magenta guibg=#0000ff

	hi! MyTabLineFill term=underline cterm=underline gui=underline

	hi! TabLineFillEnd term=underline cterm=underline gui=underline
				\ ctermfg=white ctermbg=black guifg=white guibg=black

	hi! MyTabLineSel  term=bold,reverse,underline 
				\ ctermfg=white ctermbg=blue guifg=#ffff00 guibg=#0000ff gui=underline


	hi! TabModded term=underline 
				\ cterm=underline ctermfg=black ctermbg=yellow
				\ gui=underline guifg=black guibg=#c0c000


	hi! TabExit term=underline,bold ctermfg=red guifg=#ff0000 guibg=darkgrey
				\  cterm=underline gui=underline 

	hi! TabExitSel gui=underline term=underline,bold guifg=#ff0000 guibg=blue
				\  cterm=underline ctermfg=red ctermbg=blue

	hi! TabSep term=reverse,standout,underline cterm=reverse,standout,underline
				\ gui=reverse,standout,underline
				\ ctermfg=black ctermbg=white


	hi! link TabLineFill MyTabLineFill
	hi! link TabLineSel  MyTabLineSel
endfunction

" Do this to make sure it sticks after other startup highlighting is
" complete:
autocmd GUIEnter * call TabLineSet_hl_init()
"autocmd TabEnter * call TabLineSet_hl_init()

" vim7:fdm=marker:foldenable:ts=4:sw=4:foldclose=
