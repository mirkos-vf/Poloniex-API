    # fail
    {
        agent  => \&lwp_mock,
        resp   => { result => '{"error":"error message"}' },
        method => 'fail'
    }