! �T�u���[�`�� CUT  �L���m�s�[��C�󋵂̌v�Z
! 99/06/0x ���
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE CANOPY_AIR ( 
     I  NSTR           , NEND           , INSFLAG      , 
     I  ICHECK         , 
     I  FLAG_DRY_CNP   , FLAG_DRY_SKIN  , 
     I  CVR_VEG_msx    , CVR_VEG_INV_msx, 
     I  R_AC_BAR       , R_AC_BAR_INV   , 
     I  R_AG           , R_AG_INV       , 
     I  R_STM_BAR      , R_BB           , R_AIR_INV    , 
     I  XFR_H2O_CNP    , XFR_H2O_GRS    , 
     I  E_CNP_SAT      , E_REF          , E_SKIN_SAT    ,
     I  FAC_BSH        , 
     O  E_AIR          , 
     O  R_ACX_BAR      , R_AGX_BAR      , 
     O  R_ACX_BAR_INV  , R_AGX_BAR_INV  , 
     O  R_AB_INV   )
!
!=================================================================
! �����֘A�̕ϐ�  E_AIR, R_ACX_BAR, R_AGX_BAR �̌v�Z + RCP �̌v�Z
!================================================================
!
!  ���Ă��邱��
!    ��̓I�ɂ�
!      �L���m�s�[��Ԃł̐����C��             E_AIR 
!      �L���m�s�[�̗t�̋C�E��R 
!          + �t�̕\�ʂƃL���m�s�[��ԊԂ̒�R R_ACX_BAR 
!      ����      �̗t�̋C�E��R 
!          + �t�̕\�ʂƃL���m�s�[��ԊԂ̒�R R_AGX_BAR
!    �����߂�B
!
!    �����́A�L���m�s�[��Ԃ��ߖO�a���ǂ����ŏ󋵂��ς��A�l���傫���ς��B
!    �ߖO�a���ǂ����̃t���O 
!       FLAG_DRY_CNP,FLAG_DRY_SKIN �������Ŋm�F����邱�Ƃɒ��ӁB
!
!  �v���O���}�[�ւ̒���
!
!  �E�Ⴀ��A�ᖳ���Ƃ��A����őΉ��B
!
!  �E R_AGX_BAR �͈ȑO�� RG �Ƃ͈Ⴄ�̂Œ��ӁB
!     R_AGX_BAR = RG + RD �ɂ�����B R_STM_BAR + R_AG 
!
!  �E COC, COG1, COG2 �ɂ���
!       COC  �L���m�s�[����̏����E���U�̕����R�̋t���B
!       COG1 �n�ʁE��������̏����E���U�̕����R�̋t���B
!       COG2 �n�ʁE��������̏����E���U�̕����R�̋t���A
!            ������ fac_bsh �͂����Ȃ��B
!
!  �E�o�O
!      ��ł̉���?? �̏����B�ǂ����邩�����߂Ă���ό`���邱�ƁB
!
      USE SIBPRM , ONLY :
     1   IDX  , 
     1   ICG 
!
      IMPLICIT NONE
!
! OUTPUT 
!
      REAL(8),INTENT(INOUT) :: E_AIR (IDX)   ! �L���m�s�[��Ԃ̐����C��
      REAL(8),INTENT(INOUT) :: R_ACX_BAR   (IDX)  
!                                             ! �L���m�s�[�C�E��R+���E�w��R
      REAL(8),INTENT(INOUT) :: R_ACX_BAR_INV (IDX) 
      REAL(8),INTENT(INOUT) :: R_AGX_BAR   (IDX)   ! �����C�E��R+���E�w��R
      REAL(8),INTENT(INOUT) :: R_AGX_BAR_INV (IDX)
      REAL(8),INTENT(INOUT) :: R_AB_INV (IDX)
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NSTR
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: INSFLAG
      INTEGER,INTENT(IN)   :: ICHECK    (IDX)
      REAL(8),INTENT(IN)   :: FLAG_DRY_CNP   (IDX)  
      REAL(8),INTENT(IN)   :: FLAG_DRY_SKIN  (IDX)  
!
      REAL(8),INTENT(IN)   :: XFR_H2O_CNP(IDX)      ! �L���̔G�ꂽ�����̊���
      REAL(8),INTENT(IN)   :: XFR_H2O_GRS(IDX)      ! �����̔G�ꂽ�����̊���
!
      REAL(8),INTENT(IN)   :: R_STM_BAR (IDX,ICG)  ! �C�E��R
!
      REAL(8),INTENT(IN)   :: R_AC_BAR     (IDX)   ! �L���E�L����Ԋ�
      REAL(8),INTENT(IN)   :: R_AC_BAR_INV (IDX)   !   ���E�w��R 
      REAL(8),INTENT(IN)   :: R_AG         (IDX)   ! �����E�n�ʂƃL����ԊԂ�
      REAL(8),INTENT(IN)   :: R_AG_INV     (IDX)   !   ���E�w��R RD 
! 
      REAL(8),INTENT(IN)   :: R_BB         (IDX)   ! ���n����̏�����RRSOIL
!
      REAL(8),INTENT(IN)   :: CVR_VEG_msx     (IDX,ICG)  ! �A���핢��
      REAL(8),INTENT(IN)   :: CVR_VEG_INV_msx (IDX,ICG)  ! �A���핢��
!
      REAL(8),INTENT(IN)   :: FAC_BSH   (IDX)      ! f_h ( �� .. )�y�둊�Ύ��x
!
      REAL(8),INTENT(IN)   :: R_AIR_INV (IDX)      ! �L����ԂƑ�C�ŉ��w�Ԓ�R
!
      REAL(8),INTENT(IN)   :: E_CNP_SAT   (IDX)      ! TC �ł̖O�a�����C��
      REAL(8),INTENT(IN)   :: E_SKIN_SAT  (IDX)      ! TG �ł̖O�a�����C��
      REAL(8),INTENT(IN)   :: E_REF       (IDX)      ! �Q�ƃ��x���ł̐����C��
!
! WORK 
!
      REAL(8)   :: COC  (IDX) 
      REAL(8)   :: COG1 (IDX) 
      REAL(8)   :: COG2 (IDX) 
!
      INTEGER   :: I 
      REAL(8)   :: D2
      REAL(8)   :: TOP
      REAL(8)   :: XNUM
!
!   ---------------
!   >> RC �̌v�Z <<
!   ---------------
!
      DO 100 I = NSTR,NEND
      IF ( ICHECK(I).EQ.1 ) THEN
!
!  �L���m�s�[���I����
!
        IF ( FLAG_DRY_CNP(I).GT.0.5D0 ) THEN  
          R_ACX_BAR    (I) 
!Z   1       = R_STM_BAR(I,1) + 2.0D0 * R_AC_BAR(I)
     1       = R_STM_BAR(I,1) + R_AC_BAR(I)
!
          R_ACX_BAR_INV(I) 
     1       = 1. / R_ACX_BAR (I) 
!
          COC (I) 
     1       =   (1.0D0 -XFR_H2O_CNP(I)) * R_ACX_BAR_INV(I) 
!Z   1          +   XFR_H2O_CNP(I)       * R_AC_BAR_INV (I) * 0.5
     1          +   XFR_H2O_CNP(I)       * R_AC_BAR_INV (I) 
!
!  �L���m�s�[���I
!
        ELSE                        
!
          R_ACX_BAR     (I) = 1.D30
          R_ACX_BAR_INV (I) = 0. 
!Z        COC  (I)          = R_AC_BAR_INV (I) * 0.5 
          COC  (I)          = R_AC_BAR_INV (I) 
!
        END IF  
      ENDIF
 100  CONTINUE   
!
! =======================
! >> R_AGX_BAR �̌v�Z <<
! =======================
!          ���I�̈Ӗ��́A�S�ʂ����܂��͐�ŕ�����Ƃ����Ӗ��B
!          ��Ȃ�Ό��I�Ƃ��Ȃ����Ƃɒ��ӁB
!  ------------
!  > �ᖳ���� <
!  ------------
!
      IF ( INSFLAG.EQ.0 ) THEN       
!
        DO 200 I = NSTR,NEND
        IF ( ICHECK(I).EQ.1 ) THEN
!
!   �n�ʌ��I����
!
!!        IF ( FLAG_DRY_SKIN(I).GT.0.5D0 .AND. INSFLAG.EQ.1 ) THEN  
          IF ( FLAG_DRY_SKIN(I).GT.0.5D0 ) THEN                    !010725
            XNUM = XFR_H2O_GRS(I) * R_AG_INV(I) 
     1                            * CVR_VEG_msx(I,2)            ! ��������
!
            R_AGX_BAR(I) 
     1           = R_STM_BAR (I,2) 
     1             + R_AG(I) * CVR_VEG_INV_msx(I,2)
!
            R_AGX_BAR_INV (I) 
     1           = 1 / R_AGX_BAR(I) 
!
            R_AB_INV (I) 
     1           = 1 / ( R_BB(I)+R_AG(I) ) 
!
            COG2 (I)     
     1       =   XNUM                                          ! ��������
     1         + (1.0D0 - XFR_H2O_GRS(I)) * R_AGX_BAR_INV (I)  ! �������U
     1         + ( 1.0D0 - CVR_VEG_msx(I,2))  * R_AB_INV(I)    ! ���n����
!
            COG1(I)      
     1         =
     1          +  XNUM                                        ! ��������
     1          +  (1.0D0 - XFR_H2O_GRS(I)) * R_AGX_BAR_INV(I) ! �������U
     1          + ( 1.0D0 - CVR_VEG_msx(I,2)) * R_AB_INV(I)    ! ���n����
     1                                        * FAC_BSH (I)
!
!   �n�ʌ��I 
!
          ELSE      
!
!Z          R_AB_INV      (I) = 1 / (   R_BB(I)+R_AG(I) ) 
            R_AB_INV      (I) = 1 / ( 0*R_BB(I)+R_AG(I) ) 
!
            COG1(I) =  CVR_VEG_msx(I,2)        * R_AB_INV(I)    ! ��������
     1              + (1.0D0-CVR_VEG_msx(I,2)) * R_AB_INV(I)    ! ���n����
!!   1                                         * FAC_BSH(I)     ! ketsuro
!                                                          
            COG2(I) =  CVR_VEG_msx(I,2)        * R_AB_INV(I)    ! ��������
     1              + (1.0D0-CVR_VEG_msx(I,2)) * R_AB_INV(I)    ! ���n����
!
            R_AGX_BAR     (I) = 1.D30
            R_AGX_BAR_INV (I) = 0.
          END IF                                         
        ENDIF
 200    CONTINUE
!
!  ------------
!  > �Ⴀ��� <
!  ------------
!      �ᖳ���̏ꍇ�̌��I�����Ƃ��Ȃ��B���AR_BB = 0
!
      ELSE                                  ! �Ⴀ��
        DO 300 I = NSTR,NEND
        IF ( ICHECK(I).EQ.1 ) THEN
          COG1(I) = R_AG_INV(I)                                 ! ��ʏ���
          COG2(I) = COG1(I)
!
          R_AGX_BAR     (I) = 1.D30
          R_AGX_BAR_INV (I) = 0.
          R_AB_INV      (I) = R_AG_INV(I) 
        ENDIF
 300    CONTINUE  
!
      ENDIF
!
! ====================
! >> E_AIR �̌v�Z <<
! ====================
!
      DO 400 I = NSTR,NEND
      IF ( ICHECK(I).EQ.1 ) THEN
        D2     = R_AIR_INV(I)  + COC(I) + COG2(I)
        TOP    =   COC(I)   * E_CNP_SAT(I) 
     1           + E_REF(I) * R_AIR_INV(I) 
     1           + COG1(I)  * E_SKIN_SAT(I)
        E_AIR (I) = TOP / D2
      END IF
  400 CONTINUE
!
      RETURN
      END