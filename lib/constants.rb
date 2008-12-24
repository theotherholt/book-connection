module Constants
  CONDITION = [
    [ 'New',        1 ],
    [ 'Almost New', 2 ],
    [ 'Used',       3 ],
    [ 'Worn',       4 ],
    [ 'Damaged',    5 ]
  ]
  
  EMAIL_FORMAT = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/
  
  EMAIL_SELECT = { '@alumni.calvin.edu' => 1, '@students.calvin.edu' => 0 }
end