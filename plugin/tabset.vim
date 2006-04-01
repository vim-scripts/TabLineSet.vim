" ---------------------------------------------------------------------------
" -            tabset.vim  -- example for tabline configuration      "{{{
"
"
" tabset.vim
" 
" Author:		Eric Arnold ( eric_p_arnold in_the_vicinity_of yahoo.com )
" Last Change:	Sat Apr 01, 04/01/2006 2:53:43 AM
" Requires:		Vim 7
" Version: 		1.2
"
" Acknowledgements:	The skeleton came from the help pages.
"
" Synopsis:
"
"	The goals:  1) a good alternate tabline configuration script, and 2) a
"	starter script, for those wishing to customize their tabline, which
"	more detailed example than that in the help docs.
"
"	-	It does configurable dynamic field sizing.
"
"	-	The colorscheme and general presentation are more detailed than
"		the default.
"
"	-	There is a config var to turn on/off all the extra indicators.
"		It will also turn verbose mode off when too many tabs are squeezing
"		available space.
"
"	-	Added a tab-exit button to each tab (the red "!").


 

if v:version >= 700
else
	echomsg "Vim 7 or higher is required for tabset.vim"
	finish
endif

let g:TabSet_min = 4			" minimum tab width
let g:TabSet_max = 999			" maximun tab width
let g:TabSet_verbose = 1		" control the page count and modified alert
let g:TabSet_verbose_auto = 7	" turn off verbose at this tab width



function! MyTabLine()
	let verbose = g:TabSet_verbose
	let tabline_out = ''
	for pagenum in range( 1, tabpagenr('$') )

		let buflist = []
		let buflist = tabpagebuflist( pagenum )
		if len( buflist ) < 1
			continue
		endif

		let modded = ''
		for bufnum in buflist
			if getbufvar( bufnum,  '&modified' ) != 0
				let modded = '+'
			endif
		endfor

		let is_selected = pagenum == tabpagenr()

		let tabline_out .= is_selected ? '%#TabLineSel#' : '%#TabLine#'

		" set the tab page number (for mouse clicks)
		let tabline_out .= '%' . ( pagenum ) . 'T'


		let numtabs = tabpagenr('$')
		" account for space padding between tabs, and the "close" button
		let maxlen = ( &columns - ( numtabs * 3 ) - 2 ) / numtabs
		if maxlen > g:TabSet_max
			let maxlen =  g:TabSet_max
		endif
		if maxlen < g:TabSet_verbose_auto
			let verbose = 0
		endif

		" Add an indicator that some buffer in the tab is modified:
		let tablabel = ''
		if verbose && modded != ''
			let tablabel .= '%#TabModded#' . modded
			let tablabel .= is_selected ? '%#TabLineSel#' : '%#TabLine#'
			let maxlen = maxlen - 1
		endif


		" Show the number of windows in the tab:
		if verbose && len( buflist ) > 1
			let numwins = tabpagewinnr( pagenum, ("$") )
			let tablabel .= '(' 
				\ . ( is_selected ? '%#TabWinNumSel#' : '%#TabWinNum#' )
				\ . numwins
				\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )
				\ . ')'
			let maxlen = maxlen - strlen('(' . numwins . ')')
		endif


		" Add the buffer name:
		let winnr = tabpagewinnr( pagenum )
		let tabbufname = bufname(buflist[winnr - 1])
		if tabbufname == ''
			let tabbufname = '[No Name]'
		endif
		" Pad to _min
		let len = strlen( tabbufname )
		while strlen( tabbufname ) < g:TabSet_min 
					\ && strlen( tabbufname )< maxlen
			let tabbufname = tabbufname . ' '
		endwhile
		let tabbufname = fnamemodify( tabbufname, ':t' )

		let tabexit = ''
		if verbose 
			let tabexit .= ( is_selected ? '%#TabExitSel#' : '%#TabExit#' )
						\ . '%' . pagenum . 'X!%X'
			let maxlen = maxlen - 1
		endif

		let tabbufname = strpart( tabbufname, 0,  maxlen )

		let tablabel .= ' ' . tabbufname

		let tabline_out .= tablabel  . ' '

		let tabline_out .= tabexit

		let tabline_out .= '%#TabSep#' . '|'
					\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )

	endfor


	" after the last tab fill with TabLineFill and reset tab page nr
	let tabline_out .= '%#TabLineFill#%T'

	" right-align the label to close the current tab page
	if tabpagenr('$') > 1 && verbose == 0
		let tabline_out .= '%=%#TabLine#%999X X'
	endif

	return tabline_out
endfunction


"function! MyTabLabel( pagenum )
"endfunction



set tabline=%!MyTabLine()

if &showtabline < 1
	set showtabline=1	" 2=always
endif


hi! TabWinNum term=bold,underline cterm=underline gui=bold,underline
			\ ctermfg=13 guifg=Green ctermbg=8 guibg=DarkGrey
hi! TabWinNumSel term=bold,underline cterm=underline gui=bold,underline
			\ ctermfg=13 guifg=Magenta ctermbg=8 guibg=#0000ff

hi! MyTabLineFill term=underline cterm=underline gui=underline

hi! MyTabLineSel  term=bold,reverse,underline 
			\ ctermfg=11 ctermbg=12 guifg=#ffff00 guibg=#0000ff gui=underline

hi! TabModded term=underline 
			\ cterm=underline ctermfg=black ctermbg=yellow
			\ gui=underline guifg=black guibg=#c0c000


"hi! TabExit term=underline,bold ctermfg=12 guifg=white guibg=#ff0000 " red
hi! TabExit term=underline,bold ctermfg=12 guifg=#ff0000 guibg=darkgrey
			\  cterm=underline gui=underline ctermbg=8
hi! TabExitSel gui=underline term=underline,bold guifg=#ff0000 guibg=blue
			\  cterm=underline ctermbg=12 ctermfg=12


hi! TabSep term=reverse,standout,underline cterm=reverse,standout,underline
			\ gui=reverse,standout,underline


hi! link TabLineFill MyTabLineFill
hi! link TabLineSel  MyTabLineSel

" Do this to make sure it sticks after other startup highlighting is
" complete:
autocmd GUIEnter * hi! link TabLineFill MyTabLineFill
autocmd GUIEnter * hi! link TabLineSel  MyTabLineSel

" vim7:fdm=marker:foldenable:ts=4:sw=4:foldclose=
