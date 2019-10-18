! �C�E��R�̌v�Z
! 99/07/19 �ۍ␪�G �啝�ȕύX
! 99/07/30 �ۍ␪�G ��R�� *_bar �ɂ���
! 99/08/03          ���̒�R�� *_bar �ɂ���
!                   ���U�̌v�Z�i�|�e���V�����̌v�Z�j�� *_bar �ł��邱�ƂɁB
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/10/29 �ۍ␪�G �y��|�e���V�������Ⴂ�Ƃ��ɂ����U����o�O�����B
! 2001 6/18  ���Ȃ�̎蒼��  M.Oh'izumi   

      SUBROUTINE CANOPY_STRES (
     I   NSTR        , NEND        , INSFLAG      ,
     I   ITR         , ITR_MAX     , 
     I   IFLG_AFT_MOD_FLG  , IFLG_LAST , IFLG_MOD_FLG  , 
     I   NTYP        , 
     I   R_AC_BAR    , R_AG        ,
     I   E_CNP_SAT   , E_SKIN_SAT  , E_AIR      , E_AIR_SAT      , 
     I   FUNC_TMP    , 
     I   POT_SOIL    ,
     I   D_ZERO_msx  , 
     I   R_ROOT_BAR_INV  ,               CVR_VEG_INV_msx   , 
     I   FAC_EVP     , R_STM_BAR_PAR    , 
     I   XFR_H2O_CNP  , XFR_H2O_GRS  ,
#ifdef MONYOS
     I   DELT_CNP , 
#endif
     O   POT_LEAF    , R_STM_BAR   , 
!    M   FAC_TRNS_A  , FAC_TRNS_B  , KLEV_TRNS_MAX , 
     M   FAC_TRNS_A  , FAC_TRNS_B  , 
     M   FLAG_TR     , FLAG_TR_ALL   )


C    ���ӁF���U�����鎞�ɁA���̕�������

!
! �o�́E�ύX
!   POT_LEAF   (IDX,ICG)        �t�̃|�e���V����
!   R_STM_BAR  (IDX,ICG)        �C�E��R
!   FAC_TRNS_A (IDX,IDP  ,ICG)  ���U���z�W��
!   FAC_TRNS_B (IDX,IDP  ,ICG)  ���U���z�W��
!   FLAG_TR    (IDX,IDP  ,ICG)  ���U�����t���O 1 ���� 0 �Ȃ�
!
! ���U���N���蓾�Ȃ��ꍇ�Ƃ��ẮA
!   �E���I�����𖞂���              ... �ǂ̓y��w��������U�Ȃ�
!   �E�y��̃|�e���V�������\���Ⴂ
!
! ���̃T�u���[�`���ł��邱��
!   ���U���N����Ƃ��̗t�̃|�e���V�����ƋC�E��R���v�Z����B
!   ��ɏ��U�t���b�N�X�����܂����Ƃ��A�w���Ƃ̕��z�����邽�߂̌W�����v�Z
!
! ��₱��������
!   ���U���N����Ȃ��w������ꍇ�ɁA���̑w���Ȃ����̂Ƃ��Čv�Z����K�v����B
!
      USE SIBPRM , ONLY :
     1    IDX   ,
     1    ITYP  ,
     1    ICG   ,
     1    IDP
!
      USE SIBCON , ONLY :
     1   RHO_WTR_c ,
     1   HL_WTR_c
!
      USE SIBVEG , ONLY :
     1           DEP_RMEAN_co            , ! �w�������ϐ[��  (ITYP,IDP,ICG) 
     1           F_RST_DEFI_co           , ! �C�E��R�̖O���ˑ��萔 (ITYP,ICG) 
     1           F_RST_POTLMAX_co        , ! �t�̃|�e���V������� (ITYP,ICG) 
     1           F_RST_POTLMIN_co        , ! �t�̃|�e���V�������� (ITYP,ICG) 
     I           R_PLANT_co                ! �s�̒�R        (ITYP,ICG)
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : MONIT_SIB, ICN,ICS,
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL      , IMONIT_ALMA
#endif
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)   :: NSTR
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: ITR
      INTEGER,INTENT(IN)   :: ITR_MAX
!
      INTEGER,INTENT(IN)   :: INSFLAG           ! �ᖳ�� 0 �Ⴀ�� 1 
      INTEGER,INTENT(IN)   :: IFLG_AFT_MOD_FLG  ! FLAG_TR ��ύX��������t���O 
      INTEGER,INTENT(IN)   :: IFLG_LAST         ! �ŏI�t���O
      INTEGER,INTENT(IN)   :: IFLG_MOD_FLG      ! FLAG_TR ��ύX�t���O
!
      REAL(8),INTENT(IN)   :: R_AC_BAR (IDX)    ! R_AC(�L��-�L����Ԓ�R)
      REAL(8),INTENT(IN)   :: R_AG     (IDX)    ! R_AG(�n��-�L����Ԓ�R)
      REAL(8),INTENT(IN)   :: R_ROOT_BAR_INV(IDX,IDP,ICG) 
!                                               ! �e�w��(�����{�z��)��R
!
#ifdef MONYOS
      REAL(8),INTENT(IN)   :: DELT_CNP
#endif
!
      REAL(8),INTENT(IN)   :: E_CNP_SAT (IDX)    ! �L���m�s�[���x�O�a�����C��
      REAL(8),INTENT(IN)   :: E_AIR     (IDX)    ! �L���m�s�[�����C��
      REAL(8),INTENT(IN)   :: E_AIR_SAT (IDX)    ! �L���m�s�[�����C��
      REAL(8),INTENT(IN)   :: E_SKIN_SAT(IDX)    ! �n�ʉ��x�O�a�����C��
!
!     REAL(8),INTENT(IN)   :: ICHECK  (IDX)     ! �v�Z���� 1 , ���Ȃ� 0
!
      REAL(8),INTENT(IN)   :: FUNC_TMP(IDX,ICG) ! �C�E��R�̉��x�ˑ���
!
      REAL(8),INTENT(IN)   :: POT_SOIL (IDX,IDP)  ! �y���matric pot
      REAL(8),INTENT(IN)   :: D_ZERO_msx (IDX)    ! ��ʕψ�   (���G�c)
!
!     REAL(8),INTENT(IN)   :: CVR_VEG_ms (IDX,ICG)  ! �A���핢��
      REAL(8),INTENT(IN)   :: CVR_VEG_INV_msx (IDX,ICG)  ! �A���핢��
      REAL(8),INTENT(IN)   :: FAC_EVP  (IDX)      !  �σ�/P_s 
!                                                 ! ������ XX 
!
      REAL(8),INTENT(IN)   :: R_STM_BAR_PAR  (IDX,ICG) ! 
!
      INTEGER,INTENT(IN)   :: NTYP   (IDX)       ! �A���C���f�b�N�X

      REAL(8),INTENT(IN)   :: XFR_H2O_CNP (IDX)   ! �L���m�s�[�̔G��̈�̊���
      REAL(8),INTENT(IN)   :: XFR_H2O_GRS (IDX)   ! �����̔G��̈�̊���
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: R_STM_BAR  (IDX,ICG)    ! �C�E��R
      REAL(8),INTENT(OUT)  :: POT_LEAF   (IDX,ICG)    ! �t�̐����|�e���V����
!
!
! INOUT
!
      REAL(8),INTENT(INOUT)  :: FAC_TRNS_A (IDX,IDP,ICG)  
      REAL(8),INTENT(INOUT)  :: FAC_TRNS_B (IDX,IDP,ICG)  
!     INTEGER,INTENT(INOUT)  :: KLEV_TRNS_MAX(IDX,ICG)  
      REAL(8),INTENT(INOUT)  :: FLAG_TR     (IDX,IDP,ICG)  ! 
      REAL(8),INTENT(INOUT)  :: FLAG_TR_ALL (IDX,    ICG)  ! 
!
! SAVE
!
      REAL(8),SAVE  :: AA (IDX,ICG)             ! �������̌W��
      REAL(8),SAVE  :: BB (IDX,ICG)
      REAL(8),SAVE  :: SUM_ROOT_INV (IDX,ICG)
      REAL(8),SAVE  :: SUM_POT      (IDX,ICG)
!
! WORK
!
      REAL(8)     :: POT_SOIL_WRK(IDX,IDP,ICG)
      REAL(8)     :: TRNS_SOIL(IDX,IDP,ICG)
      REAL(8)     :: TRNS_ALL (IDX,    ICG)
!
      REAL(8)     :: XFR_DRY  (IDX,ICG)     ! �t�̎����Ă��Ȃ�����
!              
      REAL(8)     :: DIFF_EAX(IDX,ICG)     ! e*(Tc) or e*(Tg) - e(Ta) �� EPOT 
      REAL(8)     :: DEFI                  ! �O�� ( deficit ) 
!
      REAL(8)     :: R_AX_BAR    (IDX,ICG)     ! ��R �L����C�ƁA�t�܂��͒n��
      REAL(8)     :: R_STM_BAR_1 (IDX,ICG)     ! �C�E��R���
      REAL(8)     :: R_STM_BAR_ORG1(IDX,ICG)   ! �C�E��R���
      REAL(8)     :: R_STM_BAR_ORG2(IDX,ICG)   ! �C�E��R���
      REAL(8)     :: R_STM_BAR_ORG3(IDX,ICG)   ! �C�E��R���
      REAL(8)     :: R_STM_BAR_PAR1(IDX,ICG)   ! �C�E��R���
      REAL(8)     :: R_STM_work  (IDX)         ! �C�E��R���
!
      REAL(8)     :: CCI                   ! �������̌W��
      REAL(8)     :: DD (IDX,ICG)
      REAL(8)     :: EE
!
      REAL(8)     :: ACOEF                 ! �񎟕������̌W��
      REAL(8)     :: BCOEF
      REAL(8)     :: CCOEF
!
      REAL(8)     :: TERM                  ! �񎟕������̉��̌����̃��[�g
! 
      REAL(8)     :: FUNC_DPOT(IDX,ICG)   ! �y�됅���ˑ���
      REAL(8)     :: FUNC_DPOT_ORG(IDX,ICG)   ! �y�됅���ˑ���

      REAL(8)     :: FUNC_TMP_X
      REAL(8)     :: FUNC_TMP_MIN
!
      REAL(8)     :: FUNC_DEFI    (IDX,ICG)
      REAL(8)     :: FUNC_DEFI_ORG(IDX,ICG)
      REAL(8)     :: FUNC_DEFI_MIN
!     REAL(8)     :: FUNC_DEFI_X
!
      REAL(8)     :: DIFF               
!     REAL(8)     :: PM
!
      REAL(8),SAVE :: R_STM_BAR_MAX 
!
      REAL(8),SAVE :: POT_MIN_ADD 
      REAL(8),SAVE :: DZERO

      INTEGER      :: IVEG
      REAL(8)      :: FVEG              ! ���� IVEG=2 �ł͍l�����Ȃ�
      INTEGER      :: I
!
      REAL(8)      :: FDP_MAX
      REAL(8)      :: FDP_MIN
      REAL(8),PARAMETER   :: SMALL = 1.D-30
!
#ifdef MONYOS 
      CHARACTER(7) :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
      REAL(8)      :: ONE_WORK(IDX) 
      REAL(8)      :: two_WORK(IDX) 
      INTEGER      :: IFLG_MON
#endif
!
      LOGICAL,SAVE :: LFIRST
      DATA LFIRST / .TRUE. /
!
      DATA DZERO /0.D0/
      DATA POT_MIN_ADD   / 1.D-5 /
      DATA FUNC_TMP_MIN  / 1.D-3 /              ! ??
      DATA FUNC_DEFI_MIN / 1.D-1 /              ! 01/07/28 =L3SiB 
!
      DATA FDP_MIN  / 1.D-4 /
      DATA FDP_MAX  / 1.D0 /
!      
C------ after Routine SiB   2001 6/25 ----------------

      DATA R_STM_BAR_MAX  / 1.D30 /              ! ??
!      DATA R_STM_BAR_MAX / 1.D5 /              ! ??
!
      r_stm_bar     (:,:) = 1.D50 
      r_stm_bar_par1(:,:) = 1.D50 
      r_stm_bar_org1(:,:) = 1.D50 
      r_stm_bar_org2(:,:) = 1.D50 
      r_stm_bar_org3(:,:) = 1.D50 
!
!!      if ( insflag.eq.0 ) 
!!     1   write(6,*) 'ISTEP canopy_stres' , 4,R_STM_BAR_PAR(4,1) 
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_STRES 99/07 POCHAKA'  
        LFIRST = .FALSE.
      ENDIF
!
#ifdef MONYOS 
      IF ( INSFLAG.EQ.0 ) THEN
        IFLG_MON=ICN
      ELSE
        IFLG_MON=ICS
      ENDIF
#endif

!
!  =====================================================================
!  >> ���U�\�w�̂Ƃ肩����ς����Ƃ��i FLAG_TR ���ς������j�v�Z <<
!  =====================================================================
!
!  FLAG_TR �ɂ́A���U���\�ȑw�ł� 1 �A�\�łȂ��w�ł� 0 ���i�[�ρB
!  �\�ȑw�����ł́A
!      ���̒�R�̋t��          �̘a  R_ROOT_BAR_INV 
!      �|�e���V������/���̒�R �̘a  SUM_POT 
!  �ƁA
!      �������̌W�� AA �� BB   
!  ���v�Z����B
!
      IF ( IFLG_AFT_MOD_FLG .EQ.1 ) THEN
#include "noparallel_fixedform"
        DO 1000 IVEG=1,2-INSFLAG 
!
        DO 1000 I=NSTR,NEND
          IF ( FLAG_TR_ALL(I,IVEG).GT.0.5d0  ) THEN
!
            SUM_ROOT_INV(I,IVEG)  
     1      =   R_ROOT_BAR_INV(I,1,IVEG) * FLAG_TR(I,1,IVEG)
     1        + R_ROOT_BAR_INV(I,2,IVEG) * FLAG_TR(I,2,IVEG)
     1        + R_ROOT_BAR_INV(I,3,IVEG) * FLAG_TR(I,3,IVEG)
!
            SUM_POT(I,IVEG)
     1      =   R_ROOT_BAR_INV(I,1,IVEG) 
     1            * ( POT_SOIL(I,1) - DEP_RMEAN_co(NTYP(I),1,IVEG) )
     1            * FLAG_TR(I,1,IVEG)
     2        + R_ROOT_BAR_INV(I,2,IVEG) 
     2            * ( POT_SOIL(I,2) - DEP_RMEAN_co(NTYP(I),2,IVEG) )
     2            * FLAG_TR(I,2,IVEG)
!    3        + R_ROOT_BAR_INV(I,3,IVEG) 
     3        + R_ROOT_BAR_INV(I,3,IVEG)                              ! bug
     3            * ( POT_SOIL(I,3) - DEP_RMEAN_co(NTYP(I),3,IVEG) )
     3            * FLAG_TR(I,3,IVEG)
!
            FVEG = FLOAT(2-IVEG)  
!
            AA(I,IVEG) 
     1         = ( SUM_POT(I,IVEG) 
     1              - ( FVEG * D_ZERO_msx(I) 
     1                       * SUM_ROOT_INV(I,IVEG) ) ) 
     1            / (   1.0D0 
     1               + R_PLANT_co(NTYP(I),IVEG)
     1                       * SUM_ROOT_INV(I,IVEG) )      

C-------- bug 2001 6/18 MO ------------------------------------------
C       ���̒�R�Ə��U�h�L�������g�i��򌴈āA�ۍ�ҏW�A�����P�P�N�V���Q�U���j
C �@�@�@�Ɍ��L��B���̖��x��������K�v�L��


            aa(i,iveg)=rho_wtr_c*aa(i,iveg)
!----------------------------------------------------------------
            BB(I,IVEG) 
     1          = - SUM_ROOT_INV(I,IVEG) 
     1                / ( 1.0D0 
     1                     + R_PLANT_co(NTYP(I),IVEG) 
     1                       * SUM_ROOT_INV(I,IVEG)   )
!----------------------------------------------------------------

            bb(i,iveg)=rho_wtr_c*bb(i,iveg)

!----------------------------------------------------------------

          ENDIF
 1000   CONTINUE
      ENDIF
!
#include "noparallel_fixedform"
      DO 1100 IVEG=1,2-INSFLAG
!
      DO 1100 I=NSTR,NEND
        POT_SOIL_WRK(I,1,IVEG) = POT_SOIL(I,1) 
     1                           - DEP_RMEAN_co(NTYP(I),1,IVEG) 
        POT_SOIL_WRK(I,2,IVEG) = POT_SOIL(I,2) 
     1                           - DEP_RMEAN_co(NTYP(I),2,IVEG) 
        POT_SOIL_WRK(I,3,IVEG) = POT_SOIL(I,3) 
     1                           - DEP_RMEAN_co(NTYP(I),3,IVEG) 
 1100 CONTINUE  
!
!  ======================================
!  >> ���I��ԁi���U�����j�̂Ƃ��̑Ώ� <<
!  ======================================
!    ���I�ie_sat(Tc) < e_air ���̂Ƃ� �j�̏ꍇ���U�͔��������A
!    �S�ʂւ̌��I = ���̏��� �ɂȂ�B
!
!    ���ӁB
!      �s�p�ӂɂ��������ƁA�{���͌��I�����łȂ��ꍇ�ɁA�S�ʂ����
!      �������N�����Ă��܂��B
!
!    �t�̊����x XFR_DRY �A��R R_AX_BAR �A�|�e���V�����̍�
!    
#include "noparallel_fixedform"
      DO 2000 IVEG=1,2-INSFLAG
!
      DO 2000 I=NSTR,NEND
!
!  �t�̊����x�A�L���m�s�[��C�̖O�a�x�v�Z
!
        IF ( IVEG.EQ.1 ) THEN
          XFR_DRY  (I,IVEG) = 1.0D0 - XFR_H2O_CNP(I)  
          DIFF_EAX(I,IVEG) = E_CNP_SAT(I)  - E_AIR(I)  
        ELSE
          XFR_DRY  (I,IVEG) = 1.0D0 - XFR_H2O_GRS(I)
          DIFF_EAX(I,IVEG) = E_SKIN_SAT(I) - E_AIR(I) 
        END IF
!
!  �S�ʔG��Ă�����A���I�����Ȃ���U�͂Ȃ�
!
        IF(XFR_DRY(I,IVEG).EQ.0.d0.OR.DIFF_EAX(I,IVEG).LE.0.d0) THEN
!
          FLAG_TR    (I,1,IVEG) = 0.d0 
          FLAG_TR    (I,2,IVEG) = 0.d0 
          FLAG_TR    (I,3,IVEG) = 0.d0 
          FLAG_TR_ALL(I  ,IVEG) = 0.d0 
!
          FAC_TRNS_A (I,1,IVEG) = 0.d0
          FAC_TRNS_B (I,1,IVEG) = 0.d0 
          FAC_TRNS_A (I,2,IVEG) = 0.d0
          FAC_TRNS_B (I,2,IVEG) = 0.d0 
          FAC_TRNS_A (I,3,IVEG) = 0.d0
          FAC_TRNS_B (I,3,IVEG) = 0.d0 
!
        ENDIF
 2000 CONTINUE  
!
!  ==========================
!  >> ���U����̂Ƃ��̑Ώ� <<
!  ==========================
!
      FUNC_DEFI     (:,:) = 0.
      FUNC_DEFI_ORG (:,:) = 0.
      FUNC_DPOT     (:,:) = 0.
      FUNC_DPOT_ORG (:,:) = 0.
!
#include "noparallel_fixedform"
      DO 2100 IVEG=1,2-INSFLAG
!
      DO 2100 I=NSTR,NEND
!
        IF ( FLAG_TR_ALL(I,IVEG).GT.0.5d0 ) THEN
!
!  ------------------------------
!  > �C�E��R�̊e��ˑ����̕]�� <
!  ------------------------------
!
!  �O���ˑ���
!
!Z bug    DEFI        = MAX ( DZERO, E_AIR_SAT(I) - E_AIR_SAT(I) )     ! �O��
          DEFI        = MAX ( DZERO, E_AIR_SAT(I) - E_AIR(I)     )     ! �O��
!
C-------�R�����g  2001 6/18 MO------------------------------------------------
C�[�[�[�[�[�@�@�����[�`���ł̈ȉ��̎��ɕύX
         FUNC_DEFI(I,IVEG)
     1        = (1.0D0 +  F_RST_DEFI_co(NTYP(I),IVEG) * DEFI )
     &        / (1.0D0 +  3.d0 * F_RST_DEFI_co(NTYP(I),IVEG) * DEFI )
C-----�@�@�ȉ��̓I���W�i���i���[�`���ł̓R�����g���j�̒莮
C          FUNC_DEFI   = 1.0D0 -  F_RST_DEFI_co(NTYP(I),IVEG) * DEFI 
C------------------------------------------------------------------------------

          FUNC_DEFI_ORG(I,IVEG) = FUNC_DEFI(I,IVEG) 
          FUNC_DEFI(I,IVEG) = MAX( FUNC_DEFI_MIN , FUNC_DEFI(I,IVEG) )
!             L3SiB �ɏ]���A�����l���� ( 0.1 ) 
!
!  ���x�ˑ���
!
!Z        FUNC_TMP_X  = MAX( FUNC_TMP_MIN  , FUNC_TMP(I,IVEG) )
          FUNC_TMP_X  = 1.d0 
!
!  �O���E���x�ˑ����E CVR_VEG ���l�������C�E��R
!
          r_stm_bar_par1(I,IVEG) = R_STM_BAR_PAR (I,IVEG)   ! ���j�^
!
!!      if ( insflag.eq.0 .and. i.eq.4 .and. iveg.eq. 1) 
!!     1   write(6,*) 'ISTEP canopy_stres_2' , R_STM_BAR_PAR1(i,iveg) 
          
!
          R_STM_BAR_1 (I,IVEG) 
     1        = R_STM_BAR_PAR (I,IVEG) 
     1          / ( FUNC_DEFI(I,IVEG) * FUNC_TMP_X  )
!
          R_STM_BAR_1 (I,IVEG) 
     1          = MIN ( R_STM_BAR_1(I,IVEG) , R_STM_BAR_MAX )
!
          IF ( IVEG.EQ.1 ) THEN
            R_AX_BAR(I,IVEG) = R_AC_BAR(I) 
          ELSE
            R_AX_BAR(I,IVEG) = R_AG(I) * CVR_VEG_INV_msx(I,2)
          END IF
!
!  ----------------------
!  > �񎟕������𗧂Ă� <
!  ----------------------
!
          CCI = FAC_EVP(I) * XFR_DRY (I,IVEG)
!
          DD(I,IVEG) 
     1       =   R_STM_BAR_1 (I,IVEG) 
     1              * (   F_RST_POTLMAX_co(NTYP(I),IVEG) 
     1                  - F_RST_POTLMIN_co(NTYP(I),IVEG) )
     1          - R_AX_BAR(I,IVEG) * F_RST_POTLMIN_co(NTYP(I),IVEG)
          EE = - DIFF_EAX(I,IVEG) * F_RST_POTLMIN_co(NTYP(I),IVEG)
!
!  �񎟕������̌W���ݒ�
!
          ACOEF = BB(I,IVEG) * R_AX_BAR(I,IVEG)           ! BB<0 , R_AX_BAR>0 
          BCOEF = ( - DIFF_EAX(I,IVEG) * CCI 
     1              + ( AA(I,IVEG) * R_AX_BAR(I,IVEG) 
     1                  + BB(I,IVEG) * DD(I,IVEG) ) )      
          CCOEF = AA(I,IVEG) * DD(I,IVEG) - EE * CCI
!
!  ���̃��[�g�̒��g
!
          TERM    = MAX ( DZERO , BCOEF*BCOEF - 4.0D0*ACOEF*CCOEF )
!
!  --------------------
!  > �񎟕����������� <
!  --------------------
!  ���B������ POT_LEAF ���傫�������Ƃ�B�@�i�ۍ�j

C       2001 6/19 MO memo
C                 �@�ȉ��̎��͑㐔�I�ɑ傫�������̗p��������ł���B
C                   ���l�ɂȂ����ꍇ�́A�����I��F_RST_POTLMAX_co�܂ŉ�����B
C                   �Ӗ��̂��镉�l���Q����ꂽ�ꍇ�́A���U�����Ղ�����
C                   �̗p���邱�ƂɂȂ�B


!       ACOEF < 0 �ɒ��ӁB
!       POT_LEAF < F_RST_POTLMIN_co(NTYP(I),IVEG) �Ȃ���U�͕�
!       POT_LEAF > F_RST_POTLMAX_co(NTYP(I),IVEG) �Ȃ��������
!
          POT_LEAF(I,IVEG) 
     1       = ( - BCOEF - SQRT ( TERM ) ) / ( 2.0D0 * ACOEF )
!

C--------  check quardatic eq. root   -- 2001 6/19 -------------
C          ��ŃR�����g������

C       if( POT_LEAF(I,IVEG) .gt.
C     1               F_RST_POTLMAX_co(NTYP(I),IVEG)) then
C           write(*,*) ' - Pot_leaf =', POT_LEAF(I,IVEG) 
C           write(*,*) ' + Pot_leaf =',  
C     1       ( - BCOEF + SQRT ( TERM ) ) / ( 2.0D0 * ACOEF )
C           write(*,*) ' Pot_MAX  =', F_RST_POTLMAX_co(NTYP(I),IVEG) 
C       endif
C---------------------------------------------------------------- 
!
!  F_RST_POTLMIN_co ��菬�����Ƃ��́A�C�E��R���傫���āA�����I�ɏ��U����
!
          POT_LEAF(I,IVEG) 
     1       = MAX ( POT_LEAF(I,IVEG) , 
     1               F_RST_POTLMIN_co(NTYP(I),IVEG) + POT_MIN_ADD  )
!
!  F_RST_POTLMAX_co ���傫���Ƃ��́AF_RST_POTLMAX_co �ɂ��� 
!
          POT_LEAF(I,IVEG) 
     1       = MIN ( POT_LEAF   (I,IVEG) , 
     1               F_RST_POTLMAX_co(NTYP(I),IVEG) )
!
!  �C�E��R�ɓy�됅�|�e���V�����ˑ����������� ( f(��l) �̋t�� )
!
!        FUNC_DPOT(I,IVEG)
!    1        =   ( F_RST_POTLMAX_co(NTYP(I),IVEG) 
!    1                  - F_RST_POTLMIN_co(NTYP(I),IVEG) )
!    1           / ( POT_LEAF   (I,IVEG)       
!    1                  - F_RST_POTLMIN_co(NTYP(I),IVEG) ) 
!
!  �C�E��R�ɓy�됅�|�e���V�����ˑ����������� ( f(��l) )
!
         FUNC_DPOT(I,IVEG)
     1        =   
     1             ( POT_LEAF   (I,IVEG)       
     1                  - F_RST_POTLMIN_co(NTYP(I),IVEG) ) 
     1           / ( F_RST_POTLMAX_co(NTYP(I),IVEG) 
     1                  - F_RST_POTLMIN_co(NTYP(I),IVEG) )
!
         FUNC_DPOT_ORG(I,IVEG) = FUNC_DPOT(I,IVEG) 
!
         FUNC_DPOT(I,IVEG) = MIN(FDP_MAX,MAX(FDP_MIN,FUNC_DPOT(I,IVEG)))
!        
         R_STM_BAR(I,IVEG) = R_STM_BAR_1 (I,IVEG) / FUNC_DPOT(I,IVEG) 
         R_STM_BAR_ORG1(I,IVEG) = R_STM_BAR (I,IVEG) 
!
        ENDIF 

 2100 CONTINUE
!
! ====================
! >> ���U�ʂ̉��]�� <<
! ====================
!   ���U�ʂ����ɕ]������B
!   ���̏��U�ʂ����ł���ꍇ�A
!   �y��w����̏��U�͂Ȃ��Ɣ��肵�� FLAG_TR = 0 �ɂ���
!
      IF ( IFLG_MOD_FLG.EQ.1 .OR. IFLG_LAST.EQ.1 ) THEN
        CALL RESET ( TRNS_SOIL,IDX*IDP*ICG )
!
#include "noparallel_fixedform"
        DO 3000 IVEG=1,2-INSFLAG 
!
        DO 3000 I=NSTR,NEND

          IF ( FLAG_TR_ALL(I,IVEG).GT.0.5d0  ) THEN
!
! --------------------------------
! > �y��w���Ƃ̏��U�ʂ�]������ <
! --------------------------------
!      FLAG_FR �𒲂ׂ邽�߂Ɍv�Z
!
            TRNS_ALL(I,IVEG)
     1        = - FAC_EVP(I) * ( E_CNP_SAT(I)-E_AIR(I) ) 
     1                       * XFR_DRY(I,IVEG)  
     1            / ( R_STM_BAR(I,IVEG) + R_AX_BAR(I,IVEG) ) 
!
!  ---------------------------------
!  > �w���̏��U�� TRNS_SOIL �̕]�� <
!  ---------------------------------
!      FLAG_TR �𒲂ׂ邽�߂Ɍv�Z
!      ���ӁB
!        FAC_TRNS_A, FAC_TRNS_B �͌�ɏ��U���v����e�w����
!        ���U�ʕ��z��]������̂Ɏg���B
!        A �̎O�w�ł̘a�� 0 , B �̘a�� 1 �ɂȂ�͂��ŁA
!        �e�w�ł̏��U�̘a�͑S�w�̏��U�ɓ������B
!        ... ������́A���m�ɓ������Ȃ�悤�ɂ��邽�߂ɁA�����Ƃ����U��
!            �傫���w�� A,B �𑼂��狁�߂�悤�ɒ��߂��悤�B
!            ���ꂪ����ꏊ�ɂ��Ă͌x���B
! 
!!        �����_�̃v���O�����ł́AFLAG_TR �����̌�ŕύX����邵�A
!!        canopy_air �� FC,FG �Ƃ̐�������������ƂƂ��Ă��Ȃ��̂ŁA
!!        �����I�ł͂Ȃ��B�Ƃ肠�����̏��u�ł���B
!
            FAC_TRNS_A(I,1,IVEG) 
     1        =  ( POT_SOIL_WRK(I,1,IVEG) 
     1             - SUM_POT(I,IVEG) /( SUM_ROOT_INV(I,IVEG)+SMALL) ) 
     1           * R_ROOT_BAR_INV(I,1,IVEG)
     1           * FLAG_TR(I,1,IVEG)    
!
C-------- bug 2001 6/18 MO --------------------------------------------------
C       ���̒�R�Ə��U�h�L�������g�i��򌴈āA�ۍ�ҏW�A�����P�P�N�V���Q�U���j
C �@�@�@�Ɍ��L��B���̖��x��������K�v�L��


            FAC_TRNS_A(I,1,IVEG) = FAC_TRNS_A(I,1,IVEG)*rho_wtr_c

C-------------------------------------------------------------------
            FAC_TRNS_A(I,2,IVEG) 
     1        =  ( POT_SOIL_WRK(I,2,IVEG) 
     1             - SUM_POT(I,IVEG) / (SUM_ROOT_INV(I,IVEG)+SMALL) ) 
     1           * R_ROOT_BAR_INV(I,2,IVEG)
     1           * FLAG_TR(I,2,IVEG)    
!
C----------------------------------------------------------------


            FAC_TRNS_A(I,2,IVEG) = FAC_TRNS_A(I,2,IVEG)*rho_wtr_c

C------------------------------------------------------------------
             FAC_TRNS_A(I,3,IVEG) 
     1        =  ( POT_SOIL_WRK(I,3,IVEG) 
     1             - SUM_POT(I,IVEG) / (SUM_ROOT_INV(I,IVEG)+SMALL) ) 
     1           * R_ROOT_BAR_INV(I,3,IVEG)
     1           * FLAG_TR(I,3,IVEG)    
!
C-------------------------------------------------------------------

            FAC_TRNS_A(I,3,IVEG) = FAC_TRNS_A(I,3,IVEG)*rho_wtr_c

C-------------------------------------------------------------------
#ifdef SIB_DEBUG
            DIFF =     FAC_TRNS_A(I,1,IVEG) 
     1               + FAC_TRNS_A(I,2,IVEG) 
     1               + FAC_TRNS_A(I,3,IVEG) 
            IF ( ABS(DIFF).GT.1.D-15 ) THEN
              write(*,*) 'canopy_stress warning diff is too large A' , 
     1                 i , IVEG ,  DIFF ,
     1                 FAC_TRNS_A(I,1,IVEG) ,
     1                 FAC_TRNS_A(I,2,IVEG) ,
     1                 FAC_TRNS_A(I,3,IVEG) ,
     1                 POT_SOIL_WRK(I,1,IVEG) ,
     1                 POT_SOIL_WRK(I,2,IVEG) ,
     1                 POT_SOIL_WRK(I,3,IVEG) ,
     1                 - SUM_POT(I,IVEG) /(SUM_ROOT_INV(I,IVEG)+SMALL),
     1                   SUM_POT(I,IVEG) , SUM_ROOT_INV(I,IVEG)  ,
     1                 R_ROOT_BAR_INV(I,1,IVEG) ,
     1                 R_ROOT_BAR_INV(I,2,IVEG) ,
     1                 R_ROOT_BAR_INV(I,3,IVEG)
            ENDIF
            IF ( ABS(DIFF).GT.1.D-1 ) THEN
              write(*,*) 'canopy_stress error diff is too large A'  
              stop 999
            ENDIF
#endif
!
            FAC_TRNS_B(I,1,IVEG) 

C----- bug fix��BB�ɐ��̖��x�������Ă���̂ŁA�����P�x���ɖ߂�
C     1        =   - ( 1/BB(I,IVEG) + R_PLANT_co(NTYP(I),IVEG) ) 
     1        = ( - rho_wtr_c/(BB(I,IVEG)+small)
     1            - R_PLANT_co(NTYP(I),IVEG) ) 
     1           * R_ROOT_BAR_INV(I,1,IVEG)   
     1           * FLAG_TR(I,1,IVEG)    
!
            FAC_TRNS_B(I,2,IVEG) 
C     1        =   - ( 1/BB(I,IVEG) + R_PLANT_co(NTYP(I),IVEG) ) 
     1        = ( - rho_wtr_c/(BB(I,IVEG)+small)
     1            - R_PLANT_co(NTYP(I),IVEG) ) 
     1           * R_ROOT_BAR_INV(I,2,IVEG)   
     1           * FLAG_TR(I,2,IVEG)    
!
            FAC_TRNS_B(I,3,IVEG) 
C     1        =   - ( 1/BB(I,IVEG) + R_PLANT_co(NTYP(I),IVEG) ) 
     1        = ( - rho_wtr_c/(BB(I,IVEG)+small)
     1            - R_PLANT_co(NTYP(I),IVEG) ) 
     1           * R_ROOT_BAR_INV(I,3,IVEG)   
     1           * FLAG_TR(I,3,IVEG)    
!
#ifdef SIB_DEBUG
            DIFF =     FAC_TRNS_B(I,1,IVEG) 
     1               + FAC_TRNS_B(I,2,IVEG) 
     1               + FAC_TRNS_B(I,3,IVEG) - 1.D0 
!
            IF (       ABS(DIFF)     .GT.1.D-10 
     1           .AND. ABS(DIFF+1.D0).GT.1.D-10 ) THEN
               write(*,*) 'canopy_stress warning diff is too large B' , 
     1                 i , IVEG ,  DIFF ,
     1                 FAC_TRNS_B(I,1,IVEG) ,
     1                 FAC_TRNS_B(I,2,IVEG) ,
     1                 FAC_TRNS_B(I,3,IVEG) ,
     1                 rho_wtr_c / (BB(I,IVEG)+small) ,  
     1                 rho_wtr_c , BB(I,IVEG) ,  
     1                 R_PLANT_co(NTYP(I),IVEG)  ,
     1                 R_ROOT_BAR_INV(I,1,IVEG)  , 
     1                 R_ROOT_BAR_INV(I,2,IVEG)  , 
     1                 FLAG_TR(I,1,IVEG)         ,
     1                 FLAG_TR(I,2,IVEG)         
            ENDIF
            IF (       ABS(DIFF)     .GT.1.D-1
     1           .AND. ABS(DIFF+1.D0).GT.1.D-1 ) THEN
              write(*,*) 'canopy_stress error diff is too large B'  
              stop 999
            ENDIF

#endif
!
            TRNS_SOIL(I,1,IVEG) 
     1        = - FAC_TRNS_A(I,1,IVEG) 
     1          + FAC_TRNS_B(I,1,IVEG) * TRNS_ALL(I,IVEG) 
!
            TRNS_SOIL(I,2,IVEG) 
     1        = - FAC_TRNS_A(I,2,IVEG) 
     1          + FAC_TRNS_B(I,2,IVEG) * TRNS_ALL(I,IVEG) 
!
            TRNS_SOIL(I,3,IVEG) 
     1        = - FAC_TRNS_A(I,3,IVEG) 
     1          + FAC_TRNS_B(I,3,IVEG) * TRNS_ALL(I,IVEG) 

          ENDIF
 3000   CONTINUE     
!
      ENDIF
!
!  ====================
!  >> FLAG_TR �̕ύX <<
!  ====================
!
!   FLAG_TR �̕ύX
!
      IF ( IFLG_MOD_FLG.EQ.1 .AND. IFLG_LAST.NE.1 ) THEN
#include "noparallel_fixedform"
        DO 4000 IVEG=1,2-INSFLAG 
!
        DO 4000 I=NSTR,NEND
          IF ( FLAG_TR_ALL(I,IVEG).GT.0.5d0 ) THEN

           IF (      TRNS_SOIL(I,1,IVEG).GT.0.D0 
!   �ȉ��̕����̈Ӗ����s���B
!  �R�w�̍��̊ԂŐ��̂��Ƃ�����Ȃ��悤�ɂƂ������Ƃ��H
     1       .OR. POT_LEAF(I,IVEG)-POT_SOIL_WRK(I,1,IVEG).GT.100.d0
     1          ) THEN
              FLAG_TR   (I,1,IVEG) = 0.d0 
              FAC_TRNS_A(I,1,IVEG) = 0.d0
              FAC_TRNS_B(I,1,IVEG) = 0.d0 
            ENDIF

            IF (      TRNS_SOIL(I,2,IVEG).GT.0.D0 
     1        .OR. POT_LEAF(I,IVEG)-POT_SOIL_WRK(I,2,IVEG).GT.100.d0
     1          ) THEN
              FLAG_TR   (I,2,IVEG) = 0.d0 
              FAC_TRNS_A(I,2,IVEG) = 0.d0
              FAC_TRNS_B(I,2,IVEG) = 0.d0 
            ENDIF

            IF (      TRNS_SOIL(I,3,IVEG).GT.0.D0
     1        .OR. POT_LEAF(I,IVEG)-POT_SOIL_WRK(I,3,IVEG).GT.100.d0
     1          ) THEN
              FLAG_TR   (I,3,IVEG) = 0.d0 
              FAC_TRNS_A(I,3,IVEG) = 0.d0
              FAC_TRNS_B(I,3,IVEG) = 0.d0 
            ENDIF

            FLAG_TR_ALL(I,IVEG)                  
     1         = 1.d0 -  (1.d0-FLAG_TR(I,1,IVEG)) 
     1                 * (1.d0-FLAG_TR(I,2,IVEG)) 
     1                 * (1.d0-FLAG_TR(I,3,IVEG)) 
          ENDIF
 4000   CONTINUE     
!
!
      ENDIF

!
!  =========================================================
!  >> �ǂ̑w��������U���Ȃ��ꍇ�� FAC_TRNS_* ���ɂ���B<<
!  =========================================================
!
!
#include "noparallel_fixedform"
      DO IVEG=1,2-INSFLAG 
!
      DO I=NSTR,NEND
!
        if (       abs(flag_tr_all(I,IVEG)) .GT. 0.001 
     1       .AND. abs(flag_tr_all(I,IVEG)-1) .GT. 0.001 )then
          write(6,*) 'canopy_stres flag_tr_all error' , i , iveg, 
     1                flag_tr_all(I,IVEG),
     1                 FLAG_TR(I,1,IVEG), 
     1                 FLAG_TR(I,2,IVEG), 
     1                 FLAG_TR(I,3,IVEG) 
          stop 1    
        endif
#ifdef SX6_OPTION
      end do
      end do        
      DO IVEG=1,2-INSFLAG 
      DO I=NSTR,NEND
#endif
!
        R_STM_BAR_ORG2(I,IVEG) = R_STM_BAR (I,IVEG) 
        IF ( FLAG_TR_ALL(I,IVEG).LT.0.5d0  ) THEN
          FAC_TRNS_A(I,1,IVEG) = 0.d0
          FAC_TRNS_B(I,1,IVEG) = 0.d0 
          FAC_TRNS_A(I,2,IVEG) = 0.d0
          FAC_TRNS_B(I,2,IVEG) = 0.d0 
          FAC_TRNS_A(I,3,IVEG) = 0.d0
          FAC_TRNS_B(I,3,IVEG) = 0.d0 
          R_STM_BAR (I,IVEG)   = R_STM_BAR_MAX          
          R_STM_BAR_ORG3(I,IVEG) = R_STM_BAR (I,IVEG) 
#ifdef MONYOS
          if ( iveg.eq.1 ) two_work(i) = 1. 
#endif
        ELSE 
          R_STM_BAR_ORG3(I,IVEG) = R_STM_BAR (I,IVEG) 
#ifdef MONYOS
          if ( iveg.eq.1 ) two_work(i) = 0. 
#endif
        ENDIF
      ENDDO
      ENDDO 
!
! -----------------------------------------------
! > FAC_TRNS_* �����܂�ɂ��Ђǂ��Ȃ����Ƃ̊m�F <
! -----------------------------------------------
!
#ifdef SIB_DEBUG
      IF ( IFLG_LAST.EQ.1 ) THEN
#include "noparallel_fixedform"
      DO IVEG=1,2-INSFLAG
!
      DO I=NSTR,NEND
        DIFF = (   FAC_TRNS_A(I,1,IVEG) + FAC_TRNS_A(I,2,IVEG) 
     1           + FAC_TRNS_A(I,3,IVEG) ) * FLAG_TR_ALL(I,IVEG)
        IF ( ABS(DIFF) .GT. 1.D-8 ) THEN 
          write(6,*) 'canopy_stres sum fac_trns_a' , i, IVEG, diff 
        ENDIF
!
        DIFF = (   FAC_TRNS_B(I,1,IVEG) + FAC_TRNS_B(I,2,IVEG) 
     1           + FAC_TRNS_B(I,3,IVEG) -1.D0 ) * FLAG_TR_ALL(I,IVEG)
        IF ( ABS(DIFF) .GT. 1.D-12 ) THEN 
          write(6,*) 'canopy_stres sum fac_trns_b' , i, IVEG, diff,
     1                FAC_TRNS_B(I,1,IVEG) , FAC_TRNS_B(I,2,IVEG) ,
     1                FAC_TRNS_B(I,3,IVEG) , FLAG_TR_ALL(I,IVEG)
        ENDIF
      ENDDO
      ENDDO
      ENDIF
#endif
!
!  ============================
!  >> �e�w����̏��U�̉��]�� <<
!  ============================
!    �����̖ڈ��̕]���B
!    �ڈ��̕]�������ۂ̂����Ƃǂꂾ�������Ă���̂��́A�m�F�p�B
!
#ifdef MONYOS
      IF ( IFLG_LAST.EQ.1  .AND. ITR.EQ.ITR_MAX ) THEN 
      IF ( IMONIT_LEVEL.GE.IMONIT_ALL ) THEN
!
! ���U���]��
!
        CMARK = 'WTRCL1Z' 
        CALL MONIT_SIB ( CMARK,TRNS_SOIL(1,1,1),IFLG_MON,DELT_CNP,ONE ) 
        CMARK = 'WTRCL2Z' 
        CALL MONIT_SIB ( CMARK,TRNS_SOIL(1,2,1),IFLG_MON,DELT_CNP,ONE ) 
        CMARK = 'WTRCL3Z' 
        CALL MONIT_SIB ( CMARK,TRNS_SOIL(1,3,1),IFLG_MON,DELT_CNP,ONE ) 
!
        IF ( INSFLAG.EQ.0 ) THEN
          CMARK = 'WTRGL1Z' 
          CALL MONIT_SIB ( CMARK,TRNS_SOIL(1,1,2),IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'WTRGL2Z' 
          CALL MONIT_SIB ( CMARK,TRNS_SOIL(1,2,2),IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'WTRGL3Z' 
          CALL MONIT_SIB ( CMARK,TRNS_SOIL(1,3,2),IFLG_MON,DELT_CNP,ONE) 
        ENDIF
!
! �C�E��R
!
        CMARK = 'RSTSRC'  ! �Z�g�ˑ���
        r_stm_work(:) = 1/R_STM_BAR_PAR1(:,1)
        CALL MONIT_SIB ( CMARK,R_STM_work,IFLG_MON,DELT_CNP,ONE) 
!
!!        if ( insflag.eq.0 ) 
!!     1   write(6,*) 'ISTEP canopy_stres_3' , 4 , 
!!     1              R_STM_BAR_PAR1(4,1),R_STM_work(4) 
!
        CMARK = 'RSTECC'  ! �O���ˑ���
        CALL MONIT_SIB ( CMARK,FUNC_DEFI(1,1),IFLG_MON,DELT_CNP,ONE ) 
        CMARK = 'RSTEOC'  ! �O���ˑ���
        CALL MONIT_SIB ( CMARK,FUNC_DEFI_ORG(1,1),IFLG_MON,DELT_CNP,ONE) 
        CMARK = 'RSTPCC'  ! �y��|�e���V�����ˑ���
        CALL MONIT_SIB ( CMARK,FUNC_DPOT(1,1),IFLG_MON,DELT_CNP,ONE ) 
        CMARK = 'RSTPOC'  ! �y��|�e���V�����ˑ���
        CALL MONIT_SIB ( CMARK,FUNC_DPOT_ORG(1,1),IFLG_MON,DELT_CNP,ONE) 
        CMARK = 'RSTOC'   ! �S��
        r_stm_work(:) = 1/R_STM_BAR_ORG1(:,1)
        CALL MONIT_SIB ( CMARK,R_STM_work,        IFLG_MON,DELT_CNP,ONE) 
        CMARK = 'RSTNC'   ! �S��
        r_stm_work(:) = 1/R_STM_BAR_ORG2(:,1)
        CALL MONIT_SIB ( CMARK,R_STM_work,        IFLG_MON,DELT_CNP,ONE) 
        CMARK = 'RSTMC'   ! �S��
        r_stm_work(:) = 1/R_STM_BAR_ORG3(:,1)
        CALL MONIT_SIB ( CMARK,R_STM_work,        IFLG_MON,DELT_CNP,ONE) 
        CMARK = 'RSTCC'   ! �S��
        r_stm_work(:) = 1/R_STM_BAR(:,1)
        CALL MONIT_SIB ( CMARK,R_STM_work,IFLG_MON,DELT_CNP,ONE) 
!
        IF ( INSFLAG.EQ.0 ) THEN
          CMARK = 'RSTSRG'
          r_stm_work(:) = 1/R_STM_BAR_PAR1(:,2)
          CALL MONIT_SIB ( CMARK,R_STM_work,IFLG_MON,DELT_CNP,ONE)      
          CMARK = 'RSTECG'
          CALL MONIT_SIB ( CMARK,FUNC_DEFI(1,2),IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTEOG'
          CALL MONIT_SIB ( CMARK,FUNC_DEFI_ORG(1,2),
     1                                          IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTPCG'
          CALL MONIT_SIB ( CMARK,FUNC_DPOT(1,2),IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTPOG'
          CALL MONIT_SIB ( CMARK,FUNC_DPOT_ORG(1,2),
     1                                          IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTOG'
          r_stm_work(:) = 1/R_STM_BAR_ORG1(:,2)
          CALL MONIT_SIB ( CMARK,R_STM_work,
     1                                          IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTNG'
          r_stm_work(:) = 1/R_STM_BAR_ORG2(:,2)
          CALL MONIT_SIB ( CMARK,R_STM_work,
     1                                          IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTMG'
          r_stm_work(:) = 1/R_STM_BAR_ORG3(:,2)
          CALL MONIT_SIB ( CMARK,R_STM_work,
     1                                          IFLG_MON,DELT_CNP,ONE) 
          CMARK = 'RSTCG'
          r_stm_work(:) = 1/R_STM_BAR(:,2)
          CALL MONIT_SIB ( CMARK,R_STM_work,IFLG_MON,DELT_CNP,ONE) 
        ENDIF
!
!
      ENDIF
        IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
          CMARK = 'A_CCOND' 
          r_stm_work(:) = 1/R_STM_BAR(:,1)
          CALL MONIT_SIB ( CMARK,R_STM_work,IFLG_MON,DELT_CNP,ONE) 
        ENDIF 
      ENDIF
#endif
!
      RETURN
      END
!=====================================================
      SUBROUTINE FLAG_TR_RESET (
     I   NSTR     , NEND       , INSFLAG , 
     I   TMP_SOIL , 
!    M   FLAG_TR  , FLAG_TR_ALL, KLEV_TRNS_MAX )
     M   FLAG_TR  , FLAG_TR_ALL )
!
      USE SIBPRM , ONLY :
     1   IDX   ,
     1   ICG   , 
     1   IDP
!
      USE SIBCON , ONLY :
     1   TMP_FREZ_c    
!
      IMPLICIT NONE 
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: INSFLAG 
      REAL(8),INTENT(IN)    :: TMP_SOIL(IDX,IDP)
!
! INOUT
!
      REAL(8),INTENT(INOUT) :: FLAG_TR       (IDX,IDP,ICG)   
      REAL(8),INTENT(INOUT) :: FLAG_TR_ALL   (IDX    ,ICG)   
!     INTEGER,INTENT(INOUT) :: KLEV_TRNS_MAX (IDX    ,ICG)   
!
! WORK
!
      INTEGER  :: I
      INTEGER  :: IVEG
      REAL(8),PARAMETER :: ONE =1.D0
!
#include "noparallel_fixedform"
      DO 1000 IVEG=1,2-INSFLAG 
!
      DO 1000 I=NSTR,NEND
        FLAG_TR      (I,1,IVEG) = 1.d0 
        FLAG_TR      (I,2,IVEG) = 1.d0 
        FLAG_TR      (I,3,IVEG) = 1.d0 
        FLAG_TR_ALL  (I,IVEG)   = 1.d0 
!       KLEV_TRNS_MAX(I,IVEG)   = 1          ! �P�Ȃ鏉���l
 1000 CONTINUE  
!
! ------------------------------------
! > ���܂��BFLAG_TR �ɏ����l��^���� <
! ------------------------------------
!  �y�����x����x�ȉ��͏��U�Ȃ�
!
      IF ( INSFLAG .EQ. 0 ) THEN
        DO 2000 I=NSTR,NEND 
          FLAG_TR(I,1,1) = 1.d0    
          FLAG_TR(I,2,1) = 1.d0 
          FLAG_TR(I,3,1) = 1.d0 
          FLAG_TR(I,1,2) = 1.d0 
          FLAG_TR(I,2,2) = 1.d0 
          FLAG_TR(I,3,2) = 1.d0 
          IF ( TMP_SOIL(I,1)   .LE. TMP_FREZ_c ) THEN 
            FLAG_TR(I,1,1) = 0.d0 
            FLAG_TR(I,1,2) = 0.d0 
          ENDIF
          IF ( TMP_SOIL(I,2) .LE. TMP_FREZ_c ) THEN 
            FLAG_TR(I,2,1) = 0.d0 
            FLAG_TR(I,2,2) = 0.d0 
          ENDIF
          IF ( TMP_SOIL(I,3) .LE. TMP_FREZ_c ) THEN 
            FLAG_TR(I,3,1) = 0.d0 
            FLAG_TR(I,3,2) = 0.d0 
          ENDIF
          FLAG_TR_ALL(I,1) =  
     1          MIN ( FLAG_TR(I,1,1) + FLAG_TR(I,2,1) + FLAG_TR(I,3,1) 
     1               , ONE )
          FLAG_TR_ALL(I,2) =  
     1          MIN ( FLAG_TR(I,1,2) + FLAG_TR(I,2,2) + FLAG_TR(I,3,2) 
     1               , ONE )
 2000   CONTINUE  
      ELSE                            ! ��ł͉�������̏��U�͖���
        DO 2100 I=NSTR,NEND 
          FLAG_TR  (I,1,1) = 1.d0 
          FLAG_TR  (I,2,1) = 1.d0 
          FLAG_TR  (I,3,1) = 1.d0 
          IF ( TMP_SOIL(I,1) .LE. TMP_FREZ_c ) THEN 
            FLAG_TR(I,1,1) = 0.d0 
          ENDIF
          IF ( TMP_SOIL(I,2) .LE. TMP_FREZ_c ) THEN 
            FLAG_TR(I,2,1) = 0.d0 
          ENDIF
          IF ( TMP_SOIL(I,3) .LE. TMP_FREZ_c ) THEN 
            FLAG_TR(I,3,1) = 0.d0 
          ENDIF
          FLAG_TR_ALL(I,1) = 
     1          MIN ( FLAG_TR(I,1,1) + FLAG_TR(I,2,1) + FLAG_TR(I,3,1) 
     1               , ONE )
!
          FLAG_TR  (I,1,2) = 0.d0 
          FLAG_TR  (I,2,2) = 0.d0 
          FLAG_TR  (I,3,2) = 0.d0 
          FLAG_TR_ALL(I,2) = 0.d0 
 2100   CONTINUE  
      ENDIF
!
      RETURN
      END
!================================================================
      SUBROUTINE MR_CANOPY_STRES
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : 
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL     , IMONIT_ALMA
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
        WRITE(6,*) 'MONIT_REGIST_CANOPY_STRES 99/09 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL.GE.IMONIT_ALL ) THEN
!
!  ���U���]��
!
      CMARK  = 'WTRCL1Z'
      CTITLE = 'WATER TRNS FROM SOIL1 VIA CANOPY (KARI)'
      CUNIT  = 'KG/M**2/S'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK  = 'WTRCL2Z'
      CTITLE = 'WATER TRNS FROM SOIL2 VIA CANOPY (KARI)'
      CUNIT  = 'KG/M**2/S'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK  = 'WTRCL3Z'
      CTITLE = 'WATER TRNS FROM SOIL3 VIA CANOPY (KARI)'
      CUNIT  = 'KG/M**2/S'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK  = 'WTRGL1Z'
      CTITLE = 'WATER TRNS FROM SOIL1 VIA GRASS (KARI)'
      CUNIT  = 'KG/M**2/S'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK  = 'WTRGL2Z'
      CTITLE = 'WATER TRNS FROM SOIL2 VIA GRASS (KARI)'
      CUNIT  = 'KG/M**2/S'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK  = 'WTRGL3Z'
      CTITLE = 'WATER TRNS FROM SOIL3 VIA GRASS (KARI)'
      CUNIT  = 'KG/M**2/S'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
!
! �C�E��R ( �Ⴀ�薳������ )
!
!   �Z�g�ˑ���
!
      CMARK = 'RSTSRG'
      CTITLE = 'registance srad grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTSRC'
      CTITLE = 'registance srad canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
!
!   �O���ˑ���
!
      CMARK = 'RSTECG'
      CTITLE = 'registance edef grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTECC'
      CTITLE = 'registance edef canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTEOG'
      CTITLE = 'registance edef grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTEOC'
      CTITLE = 'registance edef canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
!
!   �y�됅���|�e���V�����ˑ���
!
      CMARK = 'RSTPCG'
      CTITLE = 'registance potdef grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTPCC'
      CTITLE = 'registance potdef canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTPOG'
      CTITLE = 'registance potdef grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTPOC'
      CTITLE = 'registance potdef canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
!
!   �C�E��R
!
      CMARK = 'RSTCG'
      CTITLE = 'registance grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTCC'
      CTITLE = 'registance canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTOG'
      CTITLE = 'registance grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTOC'
      CTITLE = 'registance canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTNG'
      CTITLE = 'registance grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTNC'
      CTITLE = 'registance canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTMG'
      CTITLE = 'registance grass'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      CMARK = 'RSTMC'
      CTITLE = 'registance canopy'
      CUNIT  = '1'
      CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
        CMARK  = 'A_CCOND' 
        CTITLE = 'ALMA CCond (Maybe) : registance stomatol (canopy)'
        CUNIT  = '1'
        CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT )
      ENDIF 

#endif
!
      RETURN
      END