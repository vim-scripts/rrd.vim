if(match(system('rrdtool -v'), '^RRDtool ') == 0)
  augroup filetypedetect
    autocmd BufReadPre,FileReadPre		*.rrd    setlocal bin|setf rrd
    autocmd BufReadPost,FileReadPost	*.rrd    call RRDRead()| setf rrd
    autocmd BufWritePost,FileWritePost	*.rrdtmp call RRDWrite()
  augroup END
endif
