! �����E���ؗp�̌W������сA�z�ɕ]�����������E���؁B�ᖳ����B
!
! 99/06/xx �ۍ␪�G
!          ���U���������番�����Ă��Ȃ��B
! 99/07/04 ���U TRNS_N �͏����ƕʈ�����
! 99/07/17 �Ⴀ��E�ᖳ���𓝍�
!          ���ɂ��Ă͖��`�F�b�N�B
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/08/30 �ۍ␪�G �t���b�N�X�����������ɕύX
! 99/09/02 �ۍ␪�G 
! 99/09/16 �ۍ␪�G �o�O�Œ�BEVAP_TOT �� SUBL_TOT �̔z��
!
      SUBROUTINE CANOPY_EVAP (
     I  NSTR        , NEND        , e_air , 
     I  ITR         , ITR_MAX           , 
#ifdef MONYOS
     I  DELT_CNP    , INSFLAG     , 
#endif
     I  R_AIR_INV   , 
     I  R_AC_BAR_INV, R_ACX_BAR_INV , 
     I  R_AG_INV    , R_AGX_BAR_INV   , R_AB_INV   ,  
     I  E_REF       , E_TC_SAT       , E_TG_SAT     , 
     I  DEC_SAT_DTC , DEG_SAT_DTG , 
     I  CVR_VEG_ms  ,                                          ! �핢��
     I  FAC_EVP     , HUM_REL_SKIN    ,                            ! 
     I  FAC_EVP_2   , 
     I  XFR_WTR_CNP  , XFR_WTR_GRS  , XFR_WTR_BS   ,   ! ���X����
     I  XFR_GLA_CNP  , XFR_GLA_GRS  , XFR_GLA_BS   ,   ! ���X���� 
     I  FLAG_DRY_CNP      , FLAG_DRY_SKIN     ,
     I  FLAG_TR_ALL ,
     O  EVAP        , SUBL        , TRNS        , 
     O  DEVAP_DX   )
!
! �����E���ؗp�̌W������сA�z�ɕ]�����������E���؁B�ᖳ����B
! ��������̏��U�͊܂܂Ȃ��B
! 
! ����
!
!   �E�����ʂ͔M�A���̗��t���b�N�X�̌v�Z�Ɏg���B
!     ���ʂɎg����悤�ɁA���M�W���͂����Ȃ��A�����C�ʂ̕ω����Ȃǂ��o�͂���B
!
!   �E�n�ʂƐ�ʂ̏������ɂ́A(1-Cs) �� Cs �Ƃ������Ă��Ȃ��B
!     ���ꂼ��̒P�ʖʐς�����A�Ƃ��������ł���B
!
!   �E�X�͏��U���Ȃ��B
!
!   �E�����̌����́H
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    ICG    ,
     1    IWG    ,
     1    IEST   ,
     1    ICGB   ,
     1    ICGR    
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB , ICN, ICS ,
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL
#endif
!
      IMPLICIT NONE 
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
!
#ifdef MONYOS
      REAL(8),INTENT(IN)    :: DELT_CNP 
      INTEGER,INTENT(IN)    :: INSFLAG             ! �ᖳ�� 0 ����  1
#endif     
! 
      REAL(8),INTENT(IN)    :: R_AIR_INV (IDX)   ! 1/r_air   (=1/ra)
      REAL(8),INTENT(IN)    :: R_AC_BAR_INV  (IDX)   ! 1/r_ac    (=1/rb)
!     REAL(8),INTENT(IN)    :: R_CC_INV  (IDX)   ! 1/r_cc    (=1/rc) 
      REAL(8),INTENT(IN)    :: R_ACX_BAR_INV (IDX)   ! 1/(r_ac+r_cst) 
      REAL(8),INTENT(IN)    :: R_AG_INV  (IDX)   ! 1/r_d     (=1/rd) 
!     REAL(8),INTENT(IN)    :: R_BB_INV  (IDX)   ! 1/R_BB    (=1/rg)   
      REAL(8),INTENT(IN)    :: R_AGX_BAR_INV (IDX)   ! 1/(r_ag+r_gst)
      REAL(8),INTENT(IN)    :: R_AB_INV (IDX)   ! 1/(r_ag+r_bs)
!
      REAL(8),INTENT(IN)    :: E_REF   (IDX)   ! ��C�ŉ��w�䎼�i�Q�Ɣ䎼�j
      REAL(8),INTENT(IN)    :: E_TC_SAT (IDX)   ! �L�����x�O�a�䎼
      REAL(8),INTENT(IN)    :: E_TG_SAT (IDX)   ! �n�ʉ��x�O�a�䎼
!
      REAL(8),INTENT(IN)    :: DEC_SAT_DTC  (IDX)  ! �L�����x�O�a�䎼 ����
      REAL(8),INTENT(IN)    :: DEG_SAT_DTG  (IDX)  ! �n�ʉ��x�O�a�䎼 ����
!
      REAL(8),INTENT(IN)    :: CVR_VEG_ms (IDX,ICG)    ! �A���핢�� ��Ȃ� 0
!
      REAL(8),INTENT(IN)    :: FAC_EVP   (IDX)  ! �σ�/P_s ... �����C�� -> Pot
      REAL(8),INTENT(IN)    :: FAC_EVP_2 (IDX)  ! Ps/�� ... �䎼 -> �����C��
!
      REAL(8),INTENT(IN)    :: XFR_WTR_CNP(IDX)  ! �L���t   �� �핢��(���I�l��)
      REAL(8),INTENT(IN)    :: XFR_GLA_CNP(IDX)  ! �L���t   �X �핢��(���I�l��)
      REAL(8),INTENT(IN)    :: XFR_WTR_GRS(IDX)  ! �����t   �� �핢��(���I�l��)
      REAL(8),INTENT(IN)    :: XFR_GLA_GRS(IDX)  ! �����t   �X �핢��(���I�l��)
      REAL(8),INTENT(IN)    :: XFR_WTR_BS (IDX)  ! ���nor�� ���핢�� (���I�l��)
      REAL(8),INTENT(IN)    :: XFR_GLA_BS (IDX)  ! ���nor�� �X �핢��(���I�l��)
!                                               ! ���ӁB��ł� XFR_???_SNSK 
!
      REAL(8),INTENT(IN)    :: HUM_REL_SKIN (IDX)   
                                                ! �y��̔䎼�����t�@�N�^ hr
!                                               ! ���ӁB��ł� 1 
      REAL(8)               :: XHUM_REL_SKIN (IDX)   
!
      REAL(8),INTENT(IN)    :: FLAG_DRY_CNP  (IDX)  
      REAL(8),INTENT(IN)    :: FLAG_DRY_SKIN (IDX) 
!
      REAL(8),INTENT(IN)    :: FLAG_TR_ALL (IDX,ICG) ! ���U�L���t���O
!
      INTEGER,INTENT(IN)   :: ITR                  
      INTEGER,INTENT(IN)   :: ITR_MAX 

!
! OUTPUT 
!
      REAL(8),INTENT(OUT)   :: EVAP       (IDX,ICGB) ! ������
      REAL(8),INTENT(OUT)   :: SUBL       (IDX,ICGB) ! ���ؗ�
      REAL(8),INTENT(OUT)   :: TRNS       (IDX,ICG) ! ���U��
!
      REAL(8),INTENT(OUT)   :: DEVAP_DX (IDX,IEST,ICGB,ICGR)  
!                                            �����U    �L�n�Q
!                                                 �L����
! WORK 
!
      REAL(8),intent(in)    :: E_AIR      (IDX)    ! �L���m�s�[��ԋ�C�䎼
#ifdef SIB_DEBUG
      REAL(8)               :: E_AIR_XXX  (IDX)    ! �L���m�s�[��ԋ�C�䎼
#endif
      REAL(8)               :: FAC_RGST   (IDX)    
!
      REAL(8)               :: FAC_EV_CNP (IDX)    ! ��{�t�@�N�^
      REAL(8)               :: FAC_TR_CNP (IDX)     
      REAL(8)               :: FAC_SL_CNP (IDX)
      REAL(8)               :: FAC_EV_GRS (IDX)
      REAL(8)               :: FAC_TR_GRS (IDX)
      REAL(8)               :: FAC_SL_GRS (IDX)
      REAL(8)               :: FAC_EV_BS  (IDX)
      REAL(8)               :: FAC_SL_BS  (IDX)
!
      REAL(8)               :: EVAP_CNP_X         ! �����v�Z�p��� 
      REAL(8)               :: EVAP_GRS_X 
      REAL(8)               :: EVAP_BS_X 
!
      REAL(8)               :: DEA_DTC (IDX)     ! DEVAP_DTX �v�Z�p��� A
      REAL(8)               :: DEA_DTG (IDX)
      REAL(8)               :: DEA_DQR (IDX)
!
      REAL(8)               :: FAC_E_CNP         ! DEVAP_DTX �v�Z�p��� B
      REAL(8)               :: FAC_S_CNP 
      REAL(8)               :: FAC_T_CNP 
      REAL(8)               :: FAC_E_GRS
      REAL(8)               :: FAC_S_GRS
      REAL(8)               :: FAC_T_GRS
      REAL(8)               :: FAC_E_BS
      REAL(8)               :: FAC_S_BS
!
!     REAL(8)   :: RNSFLAG                   ! = 1-INSFLAG  �ᖳ��1 �Ⴀ��0
!
      REAL(8)   :: EVAP_EV_CNP (IDX)         ! �����ʁA����
      REAL(8)   :: EVAP_SL_CNP (IDX)         ! ����
      REAL(8)   :: EVAP_TR_CNP (IDX)         ! ���U
      REAL(8)   :: EVAP_EV_GRS (IDX)
      REAL(8)   :: EVAP_SL_GRS (IDX)
      REAL(8)   :: EVAP_TR_GRS (IDX)
      REAL(8)   :: EVAP_EV_BS  (IDX)
      REAL(8)   :: EVAP_SL_BS  (IDX)
#ifdef MONYOS
      REAL(8),PARAMETER :: ONE = 1. 
      REAL(8)      :: WORK(IDX) 
      CHARACTER(7) :: CMARK 
      INTEGER      :: IFLG
#endif
!
      INTEGER               :: I
!
      LOGICAL,SAVE :: LFIRST
      DATA  LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_EVAP 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
!     RNSFLAG = 1. - INSFLAG 
!
!  ===========================================
!  EA �i�L���m�s�[��C�䎼�j �̕]�� --- ��Ȃ�
!  ===========================================
!
!     ��C���ւ̏��� = �L���m�s�[�E�����E�n�ʂ���̏����U
!
      DO 1000 I=NSTR,NEND 
!
        XHUM_REL_SKIN(I) = HUM_REL_SKIN(I) * FLAG_DRY_SKIN(I) 
     1                     +  (1-FLAG_DRY_SKIN(I))
!
!
!       FAC_AIRN    = R_AIR_INV(I)
!
        FAC_EV_CNP(I) = R_AC_BAR_INV (I) * XFR_WTR_CNP(I)        ! C ����
!
        FAC_SL_CNP(I) = R_AC_BAR_INV (I) * XFR_GLA_CNP(I)        ! C ����
!
        FAC_TR_CNP(I) = R_ACX_BAR_INV(I)                         ! C ���U
     1                  * (1-XFR_WTR_CNP(I)-XFR_GLA_CNP(I)) 
!!!  1                  * FLAG_DRY_CNP(I)
     1                  * FLAG_TR_ALL(I,1)
!
        FAC_EV_GRS(I) = R_AG_INV (I) * XFR_WTR_GRS(I)            ! GRS ����
     1                               * CVR_VEG_ms(I,2)              ! ��0

        FAC_SL_GRS(I) = R_AG_INV (I) * XFR_GLA_GRS(I)            ! GRS ����
     1                               * CVR_VEG_ms(I,2)              ! ��0

        FAC_TR_GRS(I) = R_AGX_BAR_INV(I)                         ! ��0
     1                  * (1-XFR_WTR_GRS(I)-XFR_GLA_GRS(I))      ! GRS ���U
!!!  1                  * FLAG_DRY_SKIN(I)
     1                  * FLAG_TR_ALL(I,2)
!
        FAC_EV_BS (I) = R_AB_INV(I) * XFR_WTR_BS(I) 
     1                                 * (1-CVR_VEG_ms(I,2))    ! ���nor�� ����
        FAC_SL_BS (I) = R_AB_INV(I) * XFR_GLA_BS(I) 
     1                                 * (1-CVR_VEG_ms(I,2))    ! ���nor�� ����
!
        FAC_RGST(I) = 1 / (    
     1                    R_AIR_INV(I)                       ! A->R
     1                  + FAC_EV_CNP (I)
     1                  + FAC_SL_CNP (I)
     1                  + FAC_TR_CNP (I)
     1                  + FAC_EV_GRS (I) 
     1                  + FAC_SL_GRS (I) 
     1                  + FAC_TR_GRS (I) 
     1                  + FAC_EV_BS  (I) 
     1                  + FAC_SL_BS  (I) )
!
!  keisanzumi
!
#ifdef SIB_DEBUG
        E_AIR_XXX (I) = FAC_RGST(I) 
     1    * (
     1         E_REF(I) * R_AIR_INV(I)
     1       + E_TC_SAT(I) 
     1         * ( FAC_EV_CNP(I) + FAC_SL_CNP(I) + FAC_TR_CNP(I) ) 
     1       + E_TG_SAT(I) 
     1         * (   ( FAC_EV_GRS(I) + FAC_SL_GRS(I) + FAC_TR_GRS(I) )      
     1             + ( FAC_EV_BS(I)  + FAC_SL_BS(I) ) 
     1          * XHUM_REL_SKIN(I))      
     1      )
#endif
!
!
#ifdef SIB_DEBUG 
       if ( abs((e_air(i)-e_air_xxx(i))/e_air(i)) .gt. 1.D-6 ) then
        write(6,*) 'CCCXXXX canopy_evap warning e_air diff ',
     1             i,e_air(i),e_air_xxx(i),
     1             abs((e_air(i)-e_air_xxx(i))/e_air(i))
!       stop 999
       endif
#endif
!
 1000 CONTINUE 
!
!  ======================================================
!   �����U�]�� 
!  ======================================================
!
      DO 2000 I=NSTR,NEND 
!
!   �����ʁE���ؗʁE���U��
!
        EVAP_CNP_X = FAC_EVP(I) * ( E_AIR(I) - E_TC_SAT(I) )   
!
        EVAP_GRS_X = FAC_EVP(I) * ( E_AIR(I) - E_TG_SAT(I) )   
        EVAP_BS_X  = FAC_EVP(I) 
     1                   * ( E_AIR(I) - XHUM_REL_SKIN(I)*E_TG_SAT(I) ) 
!       
#ifdef KILLEVAP
          fac_ev_cnp(i) = 0 
          fac_tr_cnp(i) = 0
          fac_sl_cnp(i) = 0
          fac_ev_grs(i) = 0
          fac_tr_grs(i) = 0
          fac_sl_grs(i) = 0
          fac_ev_bs (i) = 0
          fac_sl_bs (i) = 0
#endif
!
        EVAP_EV_CNP (I) = EVAP_CNP_X * FAC_EV_CNP(I) 
        EVAP_SL_CNP (I) = EVAP_CNP_X * FAC_SL_CNP(I) 
        EVAP_TR_CNP (I) = EVAP_CNP_X * FAC_TR_CNP(I) 
!

!       
        EVAP_EV_GRS (I) = EVAP_GRS_X * FAC_EV_GRS(I)              ! ��0
        EVAP_SL_GRS (I) = EVAP_GRS_X * FAC_SL_GRS(I)              ! ��0
        EVAP_TR_GRS (I) = EVAP_GRS_X * FAC_TR_GRS(I)              ! ��0
!       
        EVAP_EV_BS  (I) = EVAP_BS_X  * FAC_EV_BS (I)
        EVAP_SL_BS  (I) = EVAP_BS_X  * FAC_SL_BS (I)
!
!   �����U�ʂ̕]�� �i���ԏd�݁AHL �������Ă��Ȃ����Ƃɒ��Ӂj
!
!    EVAP    (IDX,ICGB) 
!    SUBL    (IDX,ICGB) 
!    TRNS    (IDX,ICG) 
!
!
        EVAP(I,1) = EVAP_EV_CNP(I) 
        TRNS(I,1) = EVAP_TR_CNP(I)  
        SUBL(I,1) = EVAP_SL_CNP(I) 
!
        EVAP(I,2) = EVAP_EV_GRS(I) 
        TRNS(I,2) = EVAP_TR_GRS(I) 
        SUBL(I,2) = EVAP_SL_GRS(I)
!
        EVAP(I,3) = EVAP_EV_BS (I)       
        SUBL(I,3) = EVAP_SL_BS (I) 
!
 2000 CONTINUE
!
!  ======================================================
!   �����U�̊e�����ʈˑ��� 
!  ======================================================
!
      DO 3000 I=NSTR,NEND
!
!  ---------------------------------------------------------
!  ��ƕϐ�  FAC_x_yyy .. �P�� Ty �ω��ŁAx ����̏���������
!  ---------------------------------------------------------
!
        FAC_E_CNP = FAC_EVP(I) * FAC_EV_CNP(I)       ! �L������
        FAC_S_CNP = FAC_EVP(I) * FAC_SL_CNP(I)       ! 
        FAC_T_CNP = FAC_EVP(I) * FAC_TR_CNP(I)       ! 
!
        FAC_E_GRS = FAC_EVP(I) * FAC_EV_GRS(I)       !          ��ł�0
        FAC_S_GRS = FAC_EVP(I) * FAC_SL_GRS(I)       !          ��ł�0
        FAC_T_GRS = FAC_EVP(I) * FAC_TR_GRS(I)       !          ��ł�0
!
!       FAC_E_BS  = FAC_EVP(I) * FAC_EV_BS (I) * XHUM_REL_SKIN(I)   
!       FAC_S_BS  = FAC_EVP(I) * FAC_SL_BS (I) * XHUM_REL_SKIN(I)  
        FAC_E_BS  = FAC_EVP(I) * FAC_EV_BS (I) 
        FAC_S_BS  = FAC_EVP(I) * FAC_SL_BS (I) 
!
!  --------------------------------
!  EA �� TC,TG,TS,QR �ˑ��� DEA_Dxx 
!  --------------------------------  
!
        DEA_DTC(I)
     1     = FAC_RGST(I) * DEC_SAT_DTC(I) 
     1          * (   R_AC_BAR_INV(I)  
     1                    * (  XFR_WTR_CNP(I)+XFR_GLA_CNP(I))     ! �����E����
     1              + R_ACX_BAR_INV(I) 
     1                    * (1-XFR_WTR_CNP(I)-XFR_GLA_CNP(I)) )  ! ���U
!    1          * FLAG_TMPMOD_CNP (I)
!
        DEA_DTG(I)
     1   = FAC_RGST(I) * DEG_SAT_DTG(I) 
     1       * (                                        
     1          CVR_VEG_ms(I,2) * R_AG_INV (I) 
     1               * (  XFR_WTR_GRS(I)+XFR_GLA_GRS(I))        ! �������� ��0
     1        + R_AGX_BAR_INV(I) 
     1               * (1-XFR_WTR_GRS(I)-XFR_GLA_GRS(I))        ! �������U ��0
     1        +(1-CVR_VEG_ms(I,2))                              ! ���n����
     1               * (  R_AB_INV (I) * XHUM_REL_SKIN(I) )       
     1         )
!    1         * FLAG_TMPMOD_SKIN (I)
!
        DEA_DQR(I) = FAC_RGST(I) * R_AIR_INV (I) 
     1               * FAC_EVP_2(I)                       
!
!  ------------------------------------------------------
!  �����U�̊e�����ʈˑ��� DEVAP_DX(IDX,IEST,ICGB,ICGR)
!  ------------------------------------------------------  
!
!    TC �ˑ���
!
        DEVAP_DX(I,1,1,1) = FAC_E_CNP * ( DEA_DTC(I) - DEC_SAT_DTC(I) )
        DEVAP_DX(I,2,1,1) = FAC_S_CNP * ( DEA_DTC(I) - DEC_SAT_DTC(I) )
        DEVAP_DX(I,3,1,1) = FAC_T_CNP * ( DEA_DTC(I) - DEC_SAT_DTC(I) )
!
        DEVAP_DX(I,1,2,1) = FAC_E_GRS * ( DEA_DTC(I) - 0 )  
        DEVAP_DX(I,2,2,1) = FAC_S_GRS * ( DEA_DTC(I) - 0 )  
        DEVAP_DX(I,3,2,1) = FAC_T_GRS * ( DEA_DTC(I) - 0 )  
!                                      ! �ȏ� 3 ���A��ł� 0 
!
        DEVAP_DX(I,1,3,1) = FAC_E_BS  * ( DEA_DTC(I) - 0 )
        DEVAP_DX(I,2,3,1) = FAC_S_BS  * ( DEA_DTC(I) - 0 )
        DEVAP_DX(I,3,3,1) = 0. 
!
!    TG �ˑ���
! 
        DEVAP_DX(I,1,1,2) = FAC_E_CNP * ( DEA_DTG(I) - 0 )       
        DEVAP_DX(I,2,1,2) = FAC_S_CNP * ( DEA_DTG(I) - 0 )
        DEVAP_DX(I,3,1,2) = FAC_T_CNP * ( DEA_DTG(I) - 0 )
!
        DEVAP_DX(I,1,2,2) = FAC_E_GRS * ( DEA_DTG(I) - DEG_SAT_DTG(I) )  
        DEVAP_DX(I,2,2,2) = FAC_S_GRS * ( DEA_DTG(I) - DEG_SAT_DTG(I) )  
        DEVAP_DX(I,3,2,2) = FAC_T_GRS * ( DEA_DTG(I) - DEG_SAT_DTG(I) )  
!                                      ! �ȏ� 3 ���A��ł� 0 
!
!       DEVAP_DX(I,1,3,2) = FAC_E_BS  * ( DEA_DTG(I) - DEG_SAT_DTG(I) )
!       DEVAP_DX(I,2,3,2) = FAC_S_BS  * ( DEA_DTG(I) - DEG_SAT_DTG(I) )
        DEVAP_DX(I,1,3,2) = FAC_E_BS  
     1                      * ( DEA_DTG(I) 
     1                          - DEG_SAT_DTG(I) * XHUM_REL_SKIN(I)   )
        DEVAP_DX(I,2,3,2) = FAC_S_BS  
     1                      * ( DEA_DTG(I) 
     1                          - DEG_SAT_DTG(I) * XHUM_REL_SKIN(I)   )
        DEVAP_DX(I,3,3,2) = 0. 
!
!    QR �ˑ���
! 
        DEVAP_DX(I,1,1,3) = FAC_E_CNP * ( DEA_DQR(I) - 0 )
        DEVAP_DX(I,2,1,3) = FAC_S_CNP * ( DEA_DQR(I) - 0 )
        DEVAP_DX(I,3,1,3) = FAC_T_CNP * ( DEA_DQR(I) - 0 )
!
        DEVAP_DX(I,1,2,3) = FAC_E_GRS * ( DEA_DQR(I) - 0 )   ! ��ł� 0      
        DEVAP_DX(I,2,2,3) = FAC_S_GRS * ( DEA_DQR(I) - 0 )   ! ��ł� 0
        DEVAP_DX(I,3,2,3) = FAC_T_GRS * ( DEA_DQR(I) - 0 )   ! ��ł� 0
!
        DEVAP_DX(I,1,3,3) = FAC_E_BS  * ( DEA_DQR(I) - 0 )
        DEVAP_DX(I,2,3,3) = FAC_S_BS  * ( DEA_DQR(I) - 0 )
        DEVAP_DX(I,3,3,3) = 0. 
!
 3000 CONTINUE
!
! ================
! >> �ڍ׃��j�^ <<
! ================
! 
#ifdef MONYOS
      IF ( ITR.EQ.ITR_MAX ) THEN
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! --------------------------
! > �e��t���b�N�X�z�I�]�� <
! --------------------------
!
!  CNP ����
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'WEVN0'
          CALL MONIT_SIB ( CMARK , EVAP_EV_CNP ,ICN, DELT_CNP , ONE )      
        ELSE
          CMARK  = 'WEVS0'
          CALL MONIT_SIB ( CMARK , EVAP_EV_CNP ,ICS, DELT_CNP , ONE )      
        ENDIF
!
!  GRS ����
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'WEVG0'
          CALL MONIT_SIB ( CMARK , EVAP_EV_GRS ,ICN, DELT_CNP , ONE )      
        ENDIF
!
!  BS ����
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'WEVL0'
          CALL MONIT_SIB ( CMARK , EVAP_EV_BS ,ICN, DELT_CNP , ONE )      
        ELSE
          CMARK  = 'WEVW0'
          CALL MONIT_SIB ( CMARK , EVAP_EV_BS ,ICS, DELT_CNP , ONE )      
        ENDIF
!
!  CNP ����
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'GSLN0'
          CALL MONIT_SIB ( CMARK , EVAP_SL_CNP ,ICN, DELT_CNP , ONE )      
        ELSE
          CMARK  = 'GSLS0'
          CALL MONIT_SIB ( CMARK , EVAP_SL_CNP ,ICS, DELT_CNP , ONE )      
        ENDIF
!
!  GRS ����
!
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'GSLG0'
          CALL MONIT_SIB ( CMARK , EVAP_SL_GRS ,ICN, DELT_CNP , ONE )      
        ENDIF
!
!  BS ����
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'GSLL0'
          CALL MONIT_SIB ( CMARK , EVAP_SL_BS ,ICN, DELT_CNP , ONE )      
        ELSE
          CMARK  = 'GSLW0'
          CALL MONIT_SIB ( CMARK , EVAP_SL_BS ,ICS, DELT_CNP , ONE )      
        ENDIF
!
! ���U
!
!   �L���m�s�[
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'WTRBNL0'
          CALL MONIT_SIB ( CMARK , EVAP_TR_CNP ,ICN, DELT_CNP , ONE )      
        ELSE
          CMARK  = 'WTRBSL0'
          CALL MONIT_SIB ( CMARK , EVAP_TR_CNP ,ICS, DELT_CNP , ONE )      
        ENDIF
!
!    ����
!
        IF ( INSFLAG .EQ. 0 ) THEN
          CMARK  = 'WTRBGL0'
          CALL MONIT_SIB ( CMARK , EVAP_TR_GRS ,ICN, DELT_CNP , ONE )      
        ENDIF
!
! -----------------------------------
! > ���n�E�ϐ�ォ��̏���/���؏ڍ� <
! -----------------------------------
!
        IF ( INSFLAG .EQ. 0 ) THEN
          IFLG = ICN
        ELSE
          IFLG = ICS
        ENDIF
!
        DO I=NSTR,NEND
          WORK(I) = E_AIR(I) - XHUM_REL_SKIN(I)*E_TG_SAT(I)  
        ENDDO 
!
        CMARK  = 'EAIR'
        CALL MONIT_SIB ( CMARK , E_AIR , IFLG , DELT_CNP , ONE )      
        CMARK  = 'RELSKIN'
        CALL MONIT_SIB ( CMARK , XHUM_REL_SKIN, IFLG, DELT_CNP, ONE )      
        CMARK  = 'ETGS'
        CALL MONIT_SIB ( CMARK , E_TG_SAT, IFLG, DELT_CNP, ONE )      
        CMARK  = 'ELDIF'
        CALL MONIT_SIB ( CMARK , WORK, IFLG, DELT_CNP, ONE )      
!
        DO I=NSTR,NEND
          WORK(I) = R_AB_INV(I) * XFR_WTR_BS(I) 
     1                                 * (1-CVR_VEG_ms(I,2))
        ENDDO 
!
        CMARK  = 'ELFACT'
        CALL MONIT_SIB ( CMARK , WORK , IFLG , DELT_CNP , ONE )      
        CMARK  = 'RABI'
        CALL MONIT_SIB ( CMARK , R_AB_INV, IFLG, DELT_CNP, ONE )      
        CMARK  = 'FRWGZ'
        CALL MONIT_SIB ( CMARK , XFR_WTR_BS, IFLG, DELT_CNP, ONE )      
        CMARK  = 'FRCVRG'
        CALL MONIT_SIB ( CMARK , CVR_VEG_ms(1,2),IFLG,DELT_CNP,ONE )      
!
! ------------------------------
! > �L���m�s�[����̏����E���U <
! ------------------------------
!
        DO I=NSTR,NEND
          WORK(I) = E_AIR(I) - E_TC_SAT(I)  
        ENDDO 
!
        CMARK  = 'ETCS'
        CALL MONIT_SIB ( CMARK , E_TC_SAT, IFLG, DELT_CNP, ONE )      
!
        CMARK  = 'ECDIF'
        CALL MONIT_SIB ( CMARK , WORK, IFLG, DELT_CNP, ONE )      
!
!       FAC_TR_CNP(I) = R_ACX_BAR_INV(I) * FLAG_TR_ALL(I,1)
!    1                  * (1-XFR_WTR_CNP(I)-XFR_GLA_CNP(I)) 
!
        DO I=NSTR,NEND
          WORK(I) = R_ACX_BAR_INV(I) * FLAG_TR_ALL(I,1)
        ENDDO 
        CMARK   = 'RACXI'
        CALL MONIT_SIB ( CMARK , WORK, IFLG, DELT_CNP, ONE )      
!
      ENDIF
!
      ENDIF
!
#endif
!
      RETURN
      END
!=========================================================
      SUBROUTINE MR_CANOPY_EVAP
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : 
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL
#endif
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      LOGICAL,SAVE ::  LFIRST 
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MONIT_REGIST_CANOPY_EVAP 99/08 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
! ----------------------------------------------------------------------
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! --------------------------
! > �e��t���b�N�X�z�I�]�� <
! --------------------------
!
! CNP �ł̏����� E_CNP 
!
      CMARK  = 'WEVN0'
      CTITLE = 'CANOPY EVAPORATION NOS explicit'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WEVS0'
      CTITLE = 'CANOPY EVAPORATION SNW explicit'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ���� �ł̏����� E_GRS
!
      CMARK  = 'WEVG0'
      CTITLE = 'GRASS EVAPORATION NOS explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ���n �ł̏����� E_BS
!
      CMARK  = 'WEVL0'
      CTITLE = 'BARE SOIL EVAPORATION explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ��ʂł̏����� E_BS
!
      CMARK  = 'WEVW0'
      CTITLE = 'SNOW EVAPORATION explicit'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! CNP �ł̏��ؗ� SUBL_CNP 
!
      CMARK  = 'GSLN0'
      CTITLE = 'CANOPY SUBL NOS explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'GSLS0'
      CTITLE = 'CANOPY SUBL SNW explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ���� �ł̏��ؗ� SUBL_GRS
!
      CMARK  = 'GSLG0'
      CTITLE = 'GRASS SUBL explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ���n �ł̏��ؗ� SUBL_BS
!
      CMARK  = 'GSLL0'
      CTITLE = 'BARE SOIL SUBL explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! �� �ł̏��ؗ� SUBL_BS
!
      CMARK  = 'GSLW0'
      CTITLE = 'SNOW SUBL explicit'
      CUNIT  = 'Kg/M**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!
! ���U
!
      CMARK  = 'WTRBNL0'
      CTITLE = 'TRANS CANOPY NOS explicit'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WTRBSL0'
      CTITLE = 'TRANS CANOPY SNW explicit'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WTRBGL0'
      CTITLE = 'TRNS GRASS explicit'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! -----------------------------------
! > ���n�E�ϐ�ォ��̏���/���؏ڍ� <
! -----------------------------------
!
!  �����C��
!
      CMARK  = 'EAIR'
      CTITLE = 'E_AIR'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'ETGS'
      CTITLE = 'Saturated E of TG '
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'ETCS'
      CTITLE = 'Saturated E of TC '
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  ���n/�����
!
      CMARK  = 'ELDIF'
      CTITLE = 'EA-EG'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'RELSKIN'
      CTITLE = 'RELATIVE HUMIDITY OF SOIL 1E_AIR'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'ELFACT'
      CTITLE = 'Factor from BS/SNOW Evap'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'RABI'
      CTITLE = 'Inverse of Resist of AB'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FRWGZ'
      CTITLE = 'Fraction of BS/Snow surf (normal=1)'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FRCVRG'
      CTITLE = 'Fraction of CVRG'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  �L���m�s�[ �����U
!
      CMARK  = 'ECDIF'
      CTITLE = 'EA-ETC'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'RACXI'
      CTITLE = 'Inverse of Resist of ACX'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
! 
      ENDIF
#endif
!
      RETURN
      END