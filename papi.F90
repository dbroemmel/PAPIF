program papi

   ! enable C bindings
   use iso_c_binding

   implicit none

   ! include PAPI constants
#include "f90papi.h"

   ! PAPI variables
   !   more or less mandatory to use the library
   integer(c_int)                               :: EventSet       ! a single PAPI event set to be used
   character(len=PAPI_MAX_STR_LEN, kind=c_char) :: EventName      ! character array ('string') to hold event names
   integer(c_int)                               :: check          ! PAPI's error flag WHICH SHOULD BE CHECKED!
   integer(c_int), allocatable                  :: EventCodes(:)  ! array of event codes for pretty processing 
   integer(c_long_long), allocatable            :: EventValues(:) ! array of event values
   integer                                      :: EventCount
   !   extra PAPI variables to query hardware info
   character(len=PAPI_MAX_STR_LEN, kind=c_char) :: vendor_str
   character(len=PAPI_MAX_STR_LEN, kind=c_char) :: model_str
   integer(c_int)                               :: ncpu
   integer(c_int)                               :: nnodes
   integer(c_int)                               :: totalcpus
   integer(c_int)                               :: vendor
   integer(c_int)                               :: model
   real(c_float)                                :: revision
   real(c_float)                                :: mhz

   ! 'code' variables
   integer           :: strt, stp, tcks               ! start, stop, and tick variable for system_clock call
   integer           :: c, d                          ! loop counters
   real              :: r, result                     ! result values
   character(len=20) :: pretty='                    ' ! left-justified pretty print

   ! initialise PAPI library, MIND THE VERSION CODE!!@$&%^@
   check = PAPI_VER_CURRENT
   call PAPIF_LIBRARY_INIT(check)

   ! get PAPI's hardware info and print select values
   call PAPIF_GET_HARDWARE_INFO(ncpu, nnodes, totalcpus, vendor, vendor_str, &
                                model, model_str, revision, mhz)
   write(*,*) 'PLATFORM:'
   write(*,*) '---------'
   write(*,'(1x,a20,": ",a)')    'Vendor'//pretty, trim(vendor_str)
   write(*,'(1x,a20,": ",a)')    'Model '//pretty, trim(model_str)
   write(*,'(1x,a20,": ",f4.2)') 'GHz   '//pretty, mhz/1000
   write(*,'(1x,a20,": ",i0)')   'CPUs  '//pretty, ncpu
   write(*,*) ''

   ! create empty event set, MIND THE PAPI_NULL!!@@#$%
   EventSet = PAPI_NULL
   call PAPIF_CREATE_EVENTSET(EventSet, check)

   ! add PAPI event by name
   EventName = "PAPI_L1_LDM"
   call PAPIF_ADD_NAMED_EVENT(EventSet, EventName, check)
   ! add PAPI events by conveniently defined parameter
   call PAPIF_ADD_EVENT(EventSet, PAPI_TOT_CYC, check)
   call PAPIF_ADD_EVENT(EventSet, PAPI_FP_INS, check)

   ! get number of PAPI events to allocate fields for names and PAPI counters
   call PAPIF_NUM_EVENTS(EventSet, EventCount, check)
   allocate(EventValues(1:EventCount))

   write(*,*) 'EXECUTING CODE:'
   write(*,*) '---------------'

   ! start the clock
   call system_clock(strt)
   ! start PAPI
   call PAPIF_START(EventSet, check)

   ! a simple minded loop-nest to keep the CPU busy for some time
   r = 0
   do d = 1,1000
      do c = 1,1000000
         r=sqrt(real(c))*cos(real(d))+r
      end do
      result = result + sin(r*3.14*4.457467*sqrt(53645./454.))
   end do
   write(*,'(1x,a20,": ",e12.5)') 'Result'//pretty, result ! to not have the compiler optimise the loop away
   write(*,*) ''

   ! stop PAPI
   call PAPIF_STOP(EventSet, EventValues, check)
   ! stop the clock
   call system_clock(stp, tcks)

   write(*,*) 'TIMING AND COUNTER RESULTS:'
   write(*,*) '---------------------------'
   ! output elapsed time
   write(*,'(1x,a20,": ",e11.5,a)') 'Elapsed time'//pretty, real(stp-strt)/tcks, ' secs'

   ! allocate array to store event codes
   allocate(EventCodes(1:EventCount))
   ! and get said event codes
   call PAPIF_LIST_EVENTS(EventSet, EventCodes, EventCount, check)

   do c = lbound(EventValues, 1), ubound(EventValues, 1)
      ! convert the code to a human readable form
      call PAPIF_EVENT_CODE_TO_NAME(EventCodes(c), EventName, check)
      ! print event name and it's value
      write(*,'(1x,a20,": ",i0)') trim(EventName)//pretty, EventValues(c)
   end do

   stop

end program papi
