with builtins;

let 
  stdin = readFile ./a.txt;

  getChar = stdin: index: lex' stdin (substring index 1 stdin) (index + 1); 

  lexString = stdin: currentIndex: index:
    if (index == (stringLength stdin) 
    || (match "[0-9[:space:]]" (toString(substring index 1 stdin)) != null)) then
      substring currentIndex index stdin #+ " [CURRENT -> ${toString(currentIndex)} INDEX -> ${toString(index)}]"
    else 
      lexString stdin currentIndex (index + 1);

  lex' = stdin: char: index: 
     
    if index == (stringLength stdin) then 
      "EOF"
    else if (match "[a-zA-Z]" (toString(char)) != null) then
      let 
        buffer = lexString stdin (index - 1) (index - 1);
      in   
        "ID:(${buffer}) " + toString(getChar stdin (index + (stringLength buffer)))
    else if char == "=" then
      "ASSIG:(${char}) " + toString(getChar stdin index)
    else if char == "+" then
      "PLUS:(${char}) " + toString(getChar stdin index)
    else if  char == "-" then
      "MINUS:(${char}) " + toString(getChar stdin index)
    else if  char == "*" then
      "MULT:(${char}) " + toString(getChar stdin index)
    else if  char == ";" then
      "SEMI:(${char}) " + toString(getChar stdin index)
    else  
      getChar stdin index;

  lex = lex' stdin (substring 0 0 stdin) 0;
in 
  lex