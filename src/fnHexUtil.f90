! Copyright 2019 Khang Hoang Nguyen
!
! Permission is hereby granted, free of charge, to any person obtaining
! a copy of this software and associated documentation files
! (the "Software"), to deal in the Software without restriction,
! including without limitation the rights to use, copy, modify, merge,
! publish, distribute, sublicense, and/or sell copies of the Software,
! and to permit persons to whom the Software is furnished to do so,
! subject to the following conditions
!
! The above copyright notice and this permission notice shall be
! included in all copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
! EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
! MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
! NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
! BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
! ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
! CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.

!| author: Khang Hoang Nguyen
!  license: <a href="https://github.com/kevinhng86/faiNumber-Fortran/blob/master/LICENSE">MIT</a>
!  since: 1.0.0.f
! 
!  <p>This module, <code>fnHexUtil</code> contains procedures for
!  working with hexadecimal strings and int32 data type.
!  </p>
!
!  @note  This module treats hexadecimal strings as bit values
!         represented by hexadecimal digits and not real numbers. Thus, 
!         hexadecimal strings parse by this module will be converted to
!         int32 values as if they are real bit values represented by 
!         hexadecimal digits.
!
!  @note  Unless stated otherwise, procedures of this module are pure
!         procedures.
module fnHexUtil
    use fnConsts
    implicit none
    integer(k_int32), parameter  ::  dmax32 = 15_k_int32
    private                      ::  dmax32
contains
    !| author: Khang Hoang Nguyen
    !  since: 1.0.0.f
    !
    !  <p>Parse the `input` string as bits represented by hexadecimal
    !  digits to an int32 value.
    !
    !  <p>This subroutine ignores leading and trailing whitespaces.
    !
    !  <p>This subroutine considers an error to has occurred:<br>
    !  1. If the `input` string only contains empty spaces.<br>
    !  2. If the `input` string have a length of zero.<br>
    !  3. If the value for either the `startpos` or `endpos` arguments
    !     is incorrect.<br>
    !  4. If the `input` string contains a value that is beyond the
    !     capacity of the int32 data type. <br>
    !  5. If the `input` string is not a valid hexadecimal string.
    !  </p>
    !
    !  @see  <a href="|url|/page/startpos-endpos-explanation.html">
    !        startpos & endpos explanation</a>
    pure subroutine hexToInt32(input, output, error, startpos, endpos)
        implicit none 
        character(len=*), intent(in)            ::  input               !! A string to be parsed as a hexadecimal string to an int32 value.
        integer(k_int32), intent(out)           ::  output              !! An int32 value of the <code>input</code> string if no error has occurred during parsing.
        logical         , intent(out)           ::  error               !! A value of `.TRUE.` if an error has occurred during parsing, or `.FALSE.`, otherwise.
        integer(k_int32), intent(in), optional  ::  startpos            !! An int32 value of the position(inclusive) of where to start parsing.
        integer(k_int32), intent(in), optional  ::  endpos              !! An int32 value of the position(inclusive) of where to end parsing.
        integer(k_int32)                        ::  c, length, start, runlen
        output = 0 ; error = .TRUE.
        
        length = len(input) ; start = 1

        if ( present(endpos) ) then
            if ( endpos < 1 ) return
            if ( endpos < length ) length = endpos
        end if
        do while ( length > 0 )
            if ( input(length:length) /= charspace ) exit
            length = length - 1
        end do

        if ( present(startpos) ) then
            if ( startpos > 1 ) start = startpos
        end if
        do while( start <= length )
            if ( input(start:start) /= charspace ) exit
            start = start + 1
        end do
        if ( start > length ) return
                
        do while ( start <= length )
            if ( input(start:start) /= charzero ) exit
            start = start + 1
        end do

        runlen = (length + 1) - start
        if ( runlen == 0 ) then
            error = .FALSE.
            return
        end if
        if ( runlen > 8 ) return
        
        output = ICHAR(input(start:start))
        if ( output > 96 ) then
            output = output - 87
        else if ( output > 64 ) then
            output = output - 55
        else 
            output = IEOR(output, czero32)
            if ( output > 9 ) return
        end if        
        if ( output > dmax32 ) return
        start = start + 1
        
        do while ( start <= length )
            c = ICHAR(input(start:start))
            if ( c > 96 ) then
                c = c - 87
            else if ( c > 64 ) then
                c = c - 55
            else
                c = IEOR(c, czero32)
                if ( c > 9 ) return
            end if
            if ( c > dmax32 ) return
            
            output = ISHFT(output, 4) + c
            
            start = start + 1
        end do

        error = .FALSE.
    end subroutine hexToInt32

    !| author: Khang Hoang Nguyen
    !  since: 1.0.0.f
    !
    !  <p>Parse the `input` string as bits represented by hexadecimal
    !  digits to an int32 value.
    !
    !  <p>This subroutine ignores leading and trailing whitespaces.
    !     
    !  <p>Error codes:<br>
    !  0 - none <br>
    !  1 - empty strings<br>
    !  2 - invalid format<br>
    !  3 - value too large for data type<br>
    !  5 - Invalid argument endpos/startpos<br>
    !  </p>
    !
    !  @note  This subroutine may take longer on unsuccessful parse cases.
    !
    !  @see  <a href="|url|/page/startpos-endpos-explanation.html">
    !        startpos & endpos explanation</a>
    pure subroutine hexToInt32TrueError(input, output, error, startpos, endpos)
        implicit none 
        character(len=*), intent(in)            ::  input               !! A string to be parsed as a hexadecimal string to an int32 value.
        integer(k_int32), intent(out)           ::  output              !! An int32 value of the <code>input</code> string if no error has occurred during parsing.
        integer(k_int32), intent(out)           ::  error               !! An int32 value of 0 on successful parse cases or a true error code on unsuccessful parse cases. 
        integer(k_int32), intent(in), optional  ::  startpos            !! An int32 value of the position(inclusive) of where to start parsing.
        integer(k_int32), intent(in), optional  ::  endpos              !! An int32 value of the position(inclusive) of where to end parsing.
        integer(k_int32)                        ::  c, length, start, runlen
        output = 0 ; error = 0

        length = len(input) ; start = 1
        
        if ( present(endpos) ) then
            if ( endpos < 1 ) goto 5
            if ( present(startpos) ) then
                if ( endpos < startpos ) goto 5
            end if
            if ( endpos < length ) length = endpos
        end if
        do while ( length > 0 )
            if ( input(length:length) /= charspace ) exit
            length = length - 1
        end do

        if ( present(startpos) ) then
            if ( startpos > length ) goto 5
            if ( startpos > 1 ) start = startpos
        end if
        do while( start <= length )
            if ( input(start:start) /= charspace ) exit
            start = start + 1
        end do
        if ( start > length ) goto 1

        do while ( start <= length ) 
            if ( input(start:start) /= charzero ) exit 
            start = start + 1
        end do

        runlen = (length + 1) - start
        if ( runlen == 0 ) return
        if ( runlen > 8 ) goto 10

        output = ICHAR(input(start:start))
        if ( output > 96 ) then
            output = output - 87
        else if ( output > 64 ) then
            output = output - 55
        else 
            output = IEOR(output, czero32)
            if ( output > 9 ) goto 2
        end if        
        if ( output > dmax32 ) goto 2
        start = start + 1
 
        do while ( start <= length )
            c = ICHAR(input(start:start))
            if ( c > 96 ) then
                c = c - 87
            else if ( c > 64 ) then
                c = c - 55
            else
                c = IEOR(c, czero32)
                if ( c > 9 ) goto 2
            end if
            if ( c > dmax32 ) goto 2

            output = ISHFT(output, 4) + c

            start = start + 1
        end do
        return
        
        1 continue
            error = 1
            return
        2 continue
            error = 2
            return
        3 continue
            error = 3
            return
        5 continue
            error = 5
            return
        10 continue
            do while ( start <= length )
                c = ICHAR(input(start:start))

                if ( c > 96 .AND. c < 103 ) then
                else if ( c > 64 .AND. c < 71 ) then
                else
                    c = IEOR(c, czero32)
                    if ( c > 9 ) goto 2
                end if

                start = start + 1
            end do
            goto 3
    end subroutine hexToInt32TrueError

    !| author: Khang Hoang Nguyen
    !  since: 1.0.0.f
    !
    !  <p>Compare two strings as hexadecimal strings by parsing them to
    !  int32 values first.
    !  </p>
    !
    !  @note  Hexadecimal strings are being parsed as bits represented 
    !         by hexadecimal digits to a signed type.
    !
    !  @see  [[hexToInt32]]
    pure subroutine hexCompareAsInt32(firstString, secondString, output, error)
        implicit none
        character(len=*), intent(in)   ::  firstString                  !! A string to be compared to the string <code>secondString</code>.
        character(len=*), intent(in)   ::  secondString                 !! A string to be compared to the string <code>firstString</code>.
        integer(k_int32), intent(out)  ::  output                       !! An int32 value of 1 if the `firstString` is larger than the `secondString`, 0 if they are both equal, or -1 if the `firstString` is smaller than the `secondString`. This value may not be a correct value if an error has occurred during parsing either one of the `input` strings.
        logical         , intent(out)  ::  error                        !! A value of `.TRUE.` if an error has occurred during parsing either one of the `input` strings. Otherwise, a value of `.FALSE.`.
        integer(k_int32)               ::  n1, n2
        logical                        ::  e1, e2
        output = 0 ; error = .FALSE.

        call hexToInt32(firstString, n1, e1)
        call hexToInt32(secondString, n2, e2)

        if ( (e1 .eqv. .TRUE.) .OR. (e2 .eqv. .TRUE.) ) then
            error = .TRUE.
            return
        end if

        if ( n1 > n2 ) output = 1
        if ( n1 < n2 ) output = -1
    end subroutine hexCompareAsInt32

    !| author: Khang Hoang Nguyen
    !  since: 1.0.0.f
    !
    !  <p>Compare two strings bases on the content of the strings 
    !  reference to int32 values. If the strings are valid hexadecimal
    !  strings that can be parsed to int32 values then they will be
    !  compared base on their int32 values. Otherwise, the strings will
    !  be compared base on the priority ranking order below.
    !
    !  <p>This function return an int32 value of 1 if the `firstString`
    !  is larger than the `secondString`, 0 if they are both equal, or
    !  -1 if the `firstString` is smaller than the `secondString`.
    !
    !  <p>Priority order ranking: (lo - hi)</br>
    !  0 - invalid format<br/>
    !  1 - value too large for data type<br/>
    !  2 - empty string (0 length or empty space)<br/>
    !  3 - valid int32
    !  </p>
    !
    !  @note  Hexadecimal strings are being parsed as bits represented
    !         by hexadecimal digits to a signed type.
    !
    !  @see  [[hexToInt32TrueError]]
    pure integer(k_int32) function hexInt32OrSmaller(firstString, secondString) result(int32Out)
        implicit none
        character(len=*), intent(in)  ::  firstString                   !! A string to be compared to the string <code>secondString</code>.
        character(len=*), intent(in)  ::  secondString                  !! A string to be compared to the string <code>firstString</code>.
        integer(k_int32)              ::  n1, n2
        integer(k_int32)              ::  e1, e2
        int32Out = 0
        
        call hexToInt32TrueError(firstString, n1, e1)
        call hexToInt32TrueError(secondString, n2, e2)
        
        if ( e1 == 1 ) then
            if ( e2 == 1 ) return
            
            if ( e2 /= 0 ) then
                int32Out = 1
            else 
                int32Out = -1
            end if

            return
        else if ( e2 == 1 ) then
            if ( e1 /= 0 ) then
                int32Out = -1
            else
                int32Out = 1
            end if
            
            return
        end if
        
        if ( e1 == 0  ) then
            if ( e2 == 0 ) then
                if ( n1 > n2 ) int32Out = 1
                if ( n1 < n2 ) int32Out = -1
                return
            end if 
            
            int32Out = 1
            return
        else if ( e2 == 0 ) then
            int32Out = -1
            return
        end if 

        if ( e1 > e2 ) int32Out = 1
        if ( e1 < e2 ) int32Out = -1        
    end function hexInt32OrSmaller
end module fnHexUtil
