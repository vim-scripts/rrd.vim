" Vim syntax file
" Language:     rrd (as XML)
" Maintainer:   Colin Keith <vim @ ckeith.clara.net>
" Last Change:  Sun Oct 20 02:15:55 EDT 2002
" Filenames:    *.rrd
" URL:          http://vim.sf.net/

if version < 600
  " echomsg "Upgrade to Vim6. Its much cooler"
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match

syn keyword rrdTags rrd version step lastupdate containedin=rrdTagFmt
syn keyword rrdTags ds name type                containedin=rrdTagFmt
syn keyword rrdTags minimal_heartbeat min max   containedin=rrdTagFmt
syn keyword rrdTags last_ds value unknown_sec   containedin=rrdTagFmt
syn keyword rrdTags rra cf pdp_per_row xff      containedin=rrdTagFmt
syn keyword rrdTags cdp_prep ds value           containedin=rrdTagFmt
syn keyword rrdTags database row v              containedin=rrdTagFmt
syn keyword rrdTags unknown_datapoints          containedin=rrdTagFmt


" Valid Values to be contained in the tags:
syn keyword rrdCounterType DST GAUGE             containedin=rrdTagType
syn keyword rrdCounterType COUNTER DERIVE        containedin=rrdTagType
syn keyword rrdCFType      AVERAGE MIN MAX LAST  containedin=rrdTagCF
syn match   rrdNum '\d\+\(\.\d\+e[+-]\d\{2}\)\?' contained
syn match   rrdNaN 'NaN'                         contained
syn match   rrdUnk 'UNKN'                        contained
syn match rrdName ' [a-z0-9A-Z.-]\{1,19} 'hs=s+1,he=e-1


" Generic XML tag (simplified):
syn match  rrdTagFmt '</\?\k\+>'     contains=rrdTags
syn region rrdComment start='<!-- ' end=' -->'

syn cluster rrdTag     contains=rrdTagFmt,rrdComment
syn cluster rrdTag_Num contains=@rrdTag,rrdNum
syn cluster rrdTag_DS  contains=@rrdTag,rrdTagName,rrdTagType
syn cluster rrdTag_DS  add=rrdTagDSN,rrdTagValue
syn cluster rrdTag_DS  add=rrdTagDSMax,rrdTagDSLastDS,@rrdTag,rrdComment
syn cluster rrdTag_RRA contains=@rrdTag,rrdTagCF,rrdTagPDP,rrdTagXFF,rrdTagCDP
syn cluster rrdTag_RRA add=rrdTagDatabase




" Block tags
syn region rrdTagRRD start='^<rrd>$' end='^</rrd>$'
  \ transparent
  \ keepend

"
syn region rrdTagDS start='^\t<ds>$' end='^\t</ds>$'
  \ transparent
  \ keepend
  \ fold
  \ contains=@rrdTag_DS

syn region rrdTagRRA start='^\t<rra>' end='^\s\+</rra>$'
  \ transparent
  \ keepend
  \ fold
  \ contains=@rrdTag_RRA

syn region rrdTagCDP start='^\t\t<cdp_prep>' end='^\t\t</cdp_prep>$'
  \ transparent
  \ keepend
  \ fold
  \ contains=@rrdTag,rrdTagDScdp
  \ containedin=rrdTagRRA

syn region rrdTagDatabase start='^\t\t<database>' end='^\t\t</database>$'
  \ transparent
  \ keepend
  \ fold
  \ contains=rrdTagRow,@rrdTag





" Value tags
syn region rrdTagMain1
  \ start='^\t<\(version\|step\|lastupdate\)> '
  \ end=' </\(version\|step\|lastupdate\)>'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num

syn region rrdTagName start='^\t\t<name> ' end=' </name>'
  \ transparent
  \ keepend
  \ contains=@rrdTag,rrdName

syn match rrdTagType    '^\t\t<type> .\+ </type>$'
  \ transparent
  \ contains=rrdCounterType,@rrdTag



" These are value containers within <ds>
syn region rrdTagDSN
  \ start='^\t\t<\(minimal_heartbeat\|min\|unknown_sec\)> '
  \ end=' </\(minimal_heartbeat\|min\|unknown_sec\)>$'
  \ keepend
  \ transparent
  \ contains=@rrdTag_Num
  \ containedin=rrdTagDS

syn region rrdTagValue start='<value> ' end=' </value>'
  \ keepend
  \ transparent
  \ contains=@rrdTag_Num,rrdNan
  \ containedin=rrdTagDS,rrdTagDScdp


syn region rrdTagDSMax start='^\t\t<max> ' end=' </max>$'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num,rrdNaN
  \ containedin=rrdTagDS

syn region rrdTagDSLastDS start='^\t\t<last_ds> ' end=' </last_ds>$'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num,rrdUnk
  \ containedin=rrdTagDS





" These are value containers within <rra> tags
syn region rrdTagDSLastDS start='^\t\t<last_ds> ' end=' </last_ds>$'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num,rrdUnk
  \ containedin=rrdTagDS

syn region rrdTagCF start='^\t\t<cf> ' end=' </cf>$'
  \ transparent
  \ keepend
  \ contains=@rrdTag,rrdCFType
  \ containedin=rrdTagRRA


syn region rrdTagRRA1
  \ start='^\t\t<\(pdp_per_row\|xff\)> '
  \ end=' </\(pdp_per_row\|xff\)>'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num
  \ containedin=rrdTagRRA




" Special use of <ds> tag:
syn region rrdTagDScdp start='^\t\t\t<ds>' end='</ds>'
  \ keepend
  \ contains=@rrdTag,rrdTagValue,rrdTagUknDP
  \ containedin=rrdTagCDP

syn region rrdTagUknDP start='<unknown_datapoints>' end='unknown_datapoints'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num
  \ containedin=rrdTagDScdp


" These are value containers within <database> tags
syn region rrdTagRow start='<row>' end='</row>'
  \ transparent
  \ keepend
  \ contains=@rrdTag,rrdTagV
  \ containedin=rrdTagDatabase

syn region rrdTagV start='<v>' end='</v>'
  \ transparent
  \ keepend
  \ contains=@rrdTag_Num,rrdNan
  \ containedin=rrdTagRow




syn sync fromstart
set foldmethod=syntax

hi def link rrdNum           Number
hi def link rrdNan           Number
hi def link rrdUnk           String

hi def link rrdTagFmt        Identifier
hi def link rrdComment       Comment
hi def link rrdTags          Statement

hi def link rrdName          String
hi def link rrdCFType        String
hi def link rrdCounterType   String
