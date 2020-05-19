MODULE MOD_flux_godunov
!===================================================================================================================================
! Godunov flux
!-----------------------------------------------------------------------------------------------------------------------------------
! IMPLICIT VARIABLE HANDLING
IMPLICIT NONE
PRIVATE
!-----------------------------------------------------------------------------------------------------------------------------------
! GLOBAL VARIABLES
!-----------------------------------------------------------------------------------------------------------------------------------
INTERFACE flux_godunov
   MODULE PROCEDURE flux_godunov
END INTERFACE
!-----------------------------------------------------------------------------------------------------------------------------------
PUBLIC  :: flux_godunov
!===================================================================================================================================

CONTAINS

SUBROUTINE flux_godunov(rho_l, rho_r, &
                        v1_l, v1_r,   &
                        v2_l, v2_r,   &
                        p_l, p_r,     &
                        flux_side     )
!===================================================================================================================================
! Godunov flux which is exact flux
!===================================================================================================================================
! MODULES
USE MOD_Equation_Vars, ONLY : gamma
USE MOD_ExactRiemann,  ONLY : exact_riemann 
!-----------------------------------------------------------------------------------------------------------------------------------
! IMPLICIT VARIABLE HANDLING
  IMPLICIT NONE
!-----------------------------------------------------------------------------------------------------------------------------------
! INPUT VARIABLES
REAL,INTENT(IN)             :: rho_l, rho_r
REAL,INTENT(IN)             :: v1_l , v1_r
REAL,INTENT(IN)             :: v2_l , v2_r
REAL,INTENT(IN)             :: p_l  , p_r
!-----------------------------------------------------------------------------------------------------------------------------------
! OUTPUT VARIABLES
REAL,INTENT(OUT)            :: flux_side(4)
!-----------------------------------------------------------------------------------------------------------------------------------
! LOCAL VARIABLES 
REAL                        :: c_l,c_r
REAL                        :: rho, v1, p, v2
!===================================================================================================================================

! Compute speed of sound for u_l and u_r
c_l = SQRT(gamma*p_l/rho_l)
c_r = SQRT(gamma*p_r/rho_r)

! Compute exact riemann solution at the cell interface
! input values:
!  gamma, rho_l, rho_r, v1_l, v1_r, p_l, p_r, c_l, c_r
! output values:
!  rho, v1, p
CALL exact_riemann(gamma,             &
                   rho_l,rho_r,rho,   &
                   v1_l ,v1_r ,v1 ,   &
                   p_l  ,p_r  ,p  ,   &
                   c_l  ,c_r  ,0.0    )

! Determine v2 at the cell interface
IF(v1.GE.0.0) THEN
   v2 = v2_l
ELSE
   v2 = v2_r
ENDIF

! Compute intercell flux 
flux_side(1) = rho*v1
flux_side(2) = rho*v1*v1 + p
flux_side(3) = rho*v1*v2
flux_side(4) = v1*(gamma/(gamma-1.0)*p+0.5*rho*(v1*v1+v2*v2))
!-----------------------------------------------------------------------------------------------------------------------------------
END SUBROUTINE flux_godunov

END MODULE MOD_flux_godunov