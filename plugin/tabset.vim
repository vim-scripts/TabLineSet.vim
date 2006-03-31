" ---------------------------------------------------------------------------
" -            tabset.vim  -- example for tabline configuration      "{{{
"
"
" tabset.vim
" 
" Author:		Eric Arnold ( eric_p_arnold in_the_vicinity_of yahoo.com )
" Last Change:	Fri Mar 31, 03/31/2006 9:28:50 PM
" Requires:		Vim 7
" Version: 		1.1
"
" Acknowledgements:	The skeleton came from the help pages.

if v:version >= 700
else
	echomsg "Vim 7 or higher is required for tabset.vim"
	finish
endif

let g:TabSet_min = 4		" minimum tab width
let g:TabSet_max = 999		" maximun tab width
let g:TabSet_verbose = 1	" control the page count and modified alert



function! MyTabLine()
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
			else
			endif
		endfor

		let is_selected = 0
		if pagenum == tabpagenr()
			let is_selected = 1
		endif

		let tabline_out .= is_selected ? '%#TabLineSel#' : '%#TabLine#'

		" set the tab page number (for mouse clicks)
		" let tabline_out .= '%' . (pagenum + 1) . 'T'
		let tabline_out .= '%' . ( pagenum ) . 'T'


		" Add an indicator that some buffer in the tab is modified:
		let tablabel = ''
		if g:TabSet_verbose && modded != ''
			let tablabel .= '%#TabModded#' . modded
			let tablabel .= is_selected ? '%#TabLineSel#' : '%#TabLine#'
		endif


		" Show the number of windows in the tab:
		let numtabs = tabpagenr('$')
		" account for space padding between tabs, and the "close" button
		let maxlen = ( &columns - ( numtabs * 2 ) - 4 ) / numtabs
		if maxlen > g:TabSet_max
			let maxlen =  g:TabSet_max
		endif
		if g:TabSet_verbose && len( buflist ) > 1
			let tablabel .= '(' 
				\ . ( is_selected ? '%#TabWinNumSel#' : '%#TabWinNum#' )
				\ . tabpagewinnr( pagenum, ("$") )
				\ . ( is_selected ? '%#TabLineSel#' : '%#TabLine#' )
				\ . ')'
		endif


		" Add the buffer name:
		let winnr = tabpagewinnr( pagenum )
		let tabbufname = bufname(buflist[winnr - 1])
		if tabbufname == ''
			let tabbufname = '[No Name]'
		endif
		while strlen( tabbufname ) < g:TabSet_min
			let tabbufname = tabbufname . " "
		endwhile
		let tabbufname = fnamemodify( tabbufname, ':t' )

		let tablabel .= strpart( tabbufname, 0,  maxlen )


		let tabline_out .= tablabel . ' |'


	endfor

	" after the last tab fill with TabLineFill and reset tab page nr
	let tabline_out .= '%#TabLineFill#%T'

	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let tabline_out .= '%=%#TabLine#%999X X'
	endif

	return tabline_out
endfunction




function! MyTabLabel( pagenum )
endfunction




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

hi! TabModded term=underline,bold ctermfg=12 guifg=Red
			\  cterm=underline gui=underline ctermbg=8 guibg=DarkGrey

hi! link TabModded Error

hi! link TabLineFill MyTabLineFill
hi! link TabLineSel  MyTabLineSel

" Do this to make sure it sticks after other startup highlighting is
" complete:
autocmd GUIEnter * hi! link TabLineFill MyTabLineFill
autocmd GUIEnter * hi! link TabLineSel  MyTabLineSel

" vim7:fdm=marker:foldenable:ts=4:sw=4:foldclose=
