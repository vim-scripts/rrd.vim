" Vim filetype plugin file
" Language:	RRD (not actually a type, but a method)
" Maintainer:	Colin Keith <vim at ckeith dot clara dot net>
" Last Change:	
" Current version is at http://vim.sf.net/scripts


setlocal foldtext=RRDfoldtext()


"
" Called when opening .rrd files to convert to XML
"
function! RRDRead()
  let b:rrdtmpfile = tempname() . '.rrdtmp'
  silent execute ':!rrdtool dump '. expand('<afile>'). ' > '.b:rrdtmpfile
  silent execute ':e '. b:rrdtmpfile
endfunction


"
" Called when writing .rrd files to cconvert them back to .rrd
"
function! RRDWrite()
  let b:rrdtmpfile = expand('%')
  let a= system('rrdtool restore '. b:rrdtmpfile. ' '.b:rrdtmpfile. '-save')

  if(a == '')
    call rename(b:rrdtmpfile.'-save', bufname("#"))
  else
    let a = strpart(a, 0, strlen(a)-1)
    echoerr "Error saving file: ". a
  endif
endfunction



"
" This sets nicer messages for the fold names:
"
function! RRDfoldtext()
  call cursor(v:foldstart, 1)
  let dash = '+'. v:folddashes

  " Datasets: <ds>
  if(match(getline(v:foldstart), '<ds>') != -1)
    let sr=search('<name> .* </name>', 'W')
    if(sr != 0 && sr < v:foldend)
      return dash. ' Dataset: '.
           \ substitute(getline(sr), '.*<name> \(.*\) </name>.*', '"\1" ', '')
    endif

  " Round Robin Archives: <rra>
  elseif(match(getline(v:foldstart), '<rra>') != -1)
    let sr =search('<cf>', 'W')
    let sr2=search('<pdp_per_row>', 'W')
    let st =search('<database>', 'W')
    if( st != 0) | let st = search('<row>.*</row>', 'W') | endif
    let st2=search('</database>', 'W')
    if( st2!= 0) | let st2= search('<row>.*</row>', 'bW') | endif

    call cursor(v:foldstart, 1)

    if(sr != 0 && sr2 != 0 && st != 0 && st2 != 0 && sr =< v:foldend &&
     \ sr2 =< v:foldend && st =< v:foldend && st2 =< v:foldend)

      let stime = substitute(getline(st ), '.*<!-- .* / \(\d\+\)', '\1', '')
      let etime = substitute(getline(st2), '.*<!-- .* / \(\d\+\)', '\1', '')
      let sec   = substitute(getline(sr2), '.*<!-- \(\d\+\) .*',   '\1', '')


      return dash. ' RRA:'. substitute(getline(sr ), '.*<cf>\(.*\)</cf>.*',
           \ '\1(sample every ', ''). s:FormatTime(sec). ' for '.
           \ s:FormatTime(etime - stime + sec). ') '
    endif

  " Databases: <database>
  elseif(match(getline(v:foldstart), '<database>') != -1)
    let sr =search('<!-- .* / \d\+ --> *<row>', 'W')

    call cursor(v:foldend, 1)
    let sr2=search('<!-- .* / \d\+ --> *<row>', 'Wb')

    if(sr  != 0 && sr2 != 0 && sr  < v:foldend && sr2 < v:foldend && sr2 > sr)
      return dash. ' Database ('.
           \  substitute(getline(sr ), '.*<!-- \(.*\) /.*', '\1 to ', '').
           \  substitute(getline(sr2), '.*<!-- \(.*\) /.*', '\1) ', '')
    endif

  " ...
  endif

  return dash. (v:foldstart-v:foldend) .
       \ ' lines:'. getline(v:foldstart). ' '
endfunction



"
"
"
command! -nargs=1 -buffer DeleteDS :call s:DeleteDS('<args>')
command! -nargs=+ -buffer AddDS    :call s:AddDS('<q-args>')


""""
" Search for the DS counting each DS as we go, if found delete
" <ds>.*</ds> and corresponding <v>.*</v> entries
function! s:DeleteDS(dsn)
  let x = col('.')
  let y = line('.')
  call cursor(1,1)

  let ds = 0

  while(search('^\s*<name> ', 'W'))
    if(match(getline('.'), '<name> '. a:dsn. ' </name>') == -1)
      let ds = ds + 1
      continue
    endif

    " Rewind to the start of the dataset
    if(!search('^\s*<ds>', 'bW'))
      echoerr "Unable to find start of dataset."
      return cursor(y, x)
    endif

    let start = line('.')

    " Find end of this dataset:
    if(!search('^\s*</ds>', 'W'))
      echoerr "Unable to find end of dataset."
      return cursor(y, x)
    endif

    " Delete the dataset
    silent execute ':'. start. ',.d'

    " Build the match pattern.
    let match = ''
    while(ds > 0)
      let match = match . '<v>[^<]*<\/v>'
      let ds = ds - 1
    endwhile

    " Delete the corresponding data
    silent execute ':%g/<row>.*<\/row>/s!\(<row>'. match. '\)<v>[^<]*<\/v>!\1!'

    return cursor(y, x)
  endwhile

  echoerr "No a dataset called '". a:dsn. "' found."
  return cursor(y, x)
endfunction



function! s:AddDS(vars)
  let x = col('.')
  let y = line('.')
  call cursor(1,1)

  " Fix args:
  let dsn = argv(0)
  let type = argv(1) ? uc(argv(1)) : 'GAUGE'
  let mhb  = argv(2) ? argv(2) : '1800'
  let min  = argv(3) ? argv(3) : '0.0000000000e+00'
  let max  = argv(4) ? argv(4) : 'NaN'

  if(type != 'GAUGE' && type != 'COUNTER' &&
   \ type != 'DERIVE' && type != 'ABSOLUTE')
    echoerr 'Bogus DST "'. type. '", defaulting to GAUGE"
    type = 'GAUGE'
  endif

  let mhb = substitute(mhb, '[^\d]', '', 'g')
  if(mhb == '') | let mhb = '1800' | endif


  if(!search('^\s*<rra>', 'W'))
    echoerr "Can't find start of archive (<rra>)"
    return cursor(y, x)
  elseif(!search('^\s*<\/ds>', 'bW'))
    echoerr "Can't find end of last dataset (</ds>)"
    return cursor(y, x)
  endif

  let ln = line('.')
  silent execute ':normal! o'
  silent execute ':normal! o	<ds>'
  silent execute ':normal! o		<name> '.  dsn.' </name>'
  silent execute ':normal! o		<type> '. type.' </type>'
  silent execute ':normal! o		<minimal_heartbeat> '. mhb.
               \ ' </minimal_heartbeat>'
  silent execute ':normal! o		<min> '. min .' </min>'
  silent execute ':normal! o		<max> '. max .' </max>'
  silent execute ':normal! o'
  silent execute ':normal! o		<!-- PDP Status -->'
  silent execute ':normal! o		<last_ds> UNKN </last_ds>'
  silent execute ':normal! o		<value> NaN </value>'
  silent execute ':normal! o		<unknown_sec> 0 </unknown_sec>'
  silent execute ':normal! o	</ds>'

  " Fix the archive data. This is the last DS so add new <v> just before </row>
  echomsg "Adding new data. This can take a *long* time. Please wait!"
  :%g/<row>.*<\/row>/s!</row>\s*$!<v> NaN </v></row>!

  " Refold
  if(has('folding'))
    :%foldclose
  endif

  return cursor(y, x)
endfunction



function! s:FormatTime(time)
  let timep = a:time
  let timed = 'sec'
  if(timep%60 == 0)
    let timep = timep/60
    let timed = 'min'
    if(timep%60 == 0)
      let timep = timep/60
      let timed = 'hr'
      if(timep%24 == 0)
        let timep = timep/24
        let timed = 'day'
      endif
    endif
  endif

  if(timep != 1) | let timed = timed . 's' | endif

  return timep. ' '. timed
endfunction

