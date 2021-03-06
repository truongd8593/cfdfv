MODULE MOD_flux_van_leer
!===================================================================================================================================
! Steger Warming
!===================================================================================================================================
! MODULES
IMPLICIT NONE
PRIVATE
!-----------------------------------------------------------------------------------------------------------------------------------
! GLOBAL VARIABLES
!-----------------------------------------------------------------------------------------------------------------------------------
INTERFACE flux_van_leer
   MODULE PROCEDURE flux_van_leer
END INTERFACE
!-----------------------------------------------------------------------------------------------------------------------------------
PUBLIC  :: flux_van_leer
!===================================================================================================================================

CONTAINS

SUBROUTINE flux_van_leer( rho_l, rho_r, &
                          v1_l, v1_r,   &
                          v2_l, v2_r,   &
                          p_l, p_r,     &
                          flux_side     )
!===================================================================================================================================
! van Leer flux splitting
!===================================================================================================================================
! MODULES
USE MOD_Equation_Vars, ONLY: gamma,gamma1,gamma1q
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
REAL         :: c_l,c_r,cm,M_l,M_r
REAL         :: e_l,e_r,H_l,H_r
REAL         :: c1
REAL         :: fp(4), fm(4)
!===================================================================================================================================

!-----------------------------------------------------------------------------------------------------------------------------------
! Calculation of sound speeds
c_l=SQRT(gamma*p_l/rho_l)
c_r=SQRT(gamma*p_r/rho_r)
cm =MAX(c_l,c_r)
!-----------------------------------------------------------------------------------------------------------------------------------

! Calculate left/right energy and enthalpy
e_r=gamma1q*p_r+0.5*rho_r*(v1_r*v1_r+v2_r*v2_r)
e_l=gamma1q*p_l+0.5*rho_l*(v1_l*v1_l+v2_l*v2_l)
H_r=(e_r + p_r)/rho_r
H_l=(e_l + p_l)/rho_l
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
! Positive flux from left to right
M_l = v1_l/c_l
if (M_l .GE. 1.) then
  fp(1) = rho_l*v1_l
  fp(2) = fp(1)*v1_l+p_l
  fp(3) = fp(1)*v2_l
  fp(4) = fp(1)*H_l
elseif (M_l .LT. 1 .AND. M_l .GT.-1) then
  c1 = gamma1*v1_l+2*c_l
  fp(1) = 0.25*rho_l*c_l*(M_l+1.)**2
  fp(2) = fp(1)*c1/gamma
  fp(3) = fp(1)*v2_l
  fp(4) = 0.5*(fp(2)*c1*gamma/(gamma*gamma-1) + fp(3)*v2_l)
else
  fp = 0.
end if

! Negative flux from right to left
M_r = v1_r/c_r
if (M_r .LE. -1.) then
  fm(1) = rho_r*v1_r
  fm(2) = fm(1)*v1_r+p_r
  fm(3) = fm(1)*v2_r
  fm(4) = fm(1)*H_r
else if (M_r .LT. 1 .AND. M_r .GT.-1) then
  c1 = gamma1*v1_r-2*c_r
  fm(1) = -0.25*rho_r*c_r*(1.-M_r)**2
  fm(2) = fm(1)*c1/gamma
  fm(3) = fm(1)*v2_r
  fm(4) = 0.5*(fm(2)*c1*gamma/(gamma*gamma-1) + fm(3)*v2_r)
else
  fm = 0.
end if

! Final flux
flux_side(:)=fp(:) + fm(:)
END SUBROUTINE flux_van_leer

END MODULE MOD_flux_van_leer
