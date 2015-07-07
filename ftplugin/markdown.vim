if exists("b:did_ftplugin")
    finish
endif

if executable('grip')
    let b:dispatch = 'grip % 8888'
endif
