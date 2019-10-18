! ���ˌv�Z�֘A�� SiB �p�̕ϐ����A�Z�[�u����B
! 99/05/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE RAD_SAVE ( 
     I    NMAX               , NMAX_01            ,
     I    JL                 , ILIST , 
     I    RAD_SHRT_NOS       , RAD_SHRT_SNW       , 
     I    R_STM_BAR_PAR_NOS  , R_STM_BAR_PAR_SNW      , 
     O    RAD_SHRT_NOS_SAVE  , RAD_SHRT_SNW_SAVE  , 
     O    R_STM_BAR_PAR_NOS_SAVE , R_STM_BAR_PAR_SNW_SAVE    )
!
! �T�v
!   ���ˌv�Z�֘A�� SiB �p�̕ϐ����A�Z�[�u����B
!   ���˂͎��ԊԈ������邪�ASiB �͖��X�e�b�v�v�Z���邽��
!
!   ��L���A�ᖳ����Ƃ�
!
! ����
!   RAD_CG �͂��̎��_�ł́A���ˊp�␳����Ȃ��Z�g���̂݁B
!
!
      USE PRM , ONLY : 
     1   IJPHY  , 
     1   JLPHY  , 
     1   ISPT 
!
      USE SIBPRM , ONLY :
     1   IDX    , 
     1   ICG 
!
      IMPLICIT NONE 
!
! INPUT
!
      REAL(8),INTENT(IN)   ::  
     1        RAD_SHRT_SNW      ( IDX  , ICG ) , ! CG �ւ̒Z�g����
     1        RAD_SHRT_NOS      ( IDX  , ICG ) , ! CG �ւ̒Z�g����
     1        R_STM_BAR_PAR_SNW ( IDX  , ICG ) , ! �C�E��RPAR�ˑ�    
     1        R_STM_BAR_PAR_NOS ( IDX  , ICG )   ! �C�E��RPAR�ˑ�    
!
      INTEGER,INTENT(IN)   ::  JL
      INTEGER,INTENT(IN)   ::  NMAX_01(3)
      INTEGER,INTENT(IN)   ::  NMAX
      INTEGER,INTENT(IN)   ::  ILIST  (IDX)  ! SiB -> �SSiB 
!
! OUTPUT
!
      REAL(8),INTENT(INOUT)  ::  
     1     RAD_SHRT_SNW_SAVE      ( ISPT*IJPHY  , JLPHY , ICG )  ,  
     1     RAD_SHRT_NOS_SAVE      ( ISPT*IJPHY  , JLPHY , ICG )  , 
     1     R_STM_BAR_PAR_SNW_SAVE ( ISPT*IJPHY  , JLPHY , ICG )  , 
     1     R_STM_BAR_PAR_NOS_SAVE ( ISPT*IJPHY  , JLPHY , ICG )   
!
! WORK
!
      INTEGER              ::  I
      INTEGER              ::  J
!
      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'RAD_SAVE 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 
!
!   ----------------------------------------
!!  >> �Z�g�v�Z�� �S�ʃf�[�^�ɃZ�[�u <<
!   ----------------------------------------
!

#include "indep_fixedform"
      DO 100 I=1,NMAX_01(3)
        J = ILIST(I) 
        RAD_SHRT_NOS_SAVE      (J,JL,1) = RAD_SHRT_NOS      (I,1)    
        RAD_SHRT_NOS_SAVE      (J,JL,2) = RAD_SHRT_NOS      (I,2)    
        R_STM_BAR_PAR_NOS_SAVE (J,JL,1) = R_STM_BAR_PAR_NOS (I,1) 
        R_STM_BAR_PAR_NOS_SAVE (J,JL,2) = R_STM_BAR_PAR_NOS (I,2) 
  100 CONTINUE
!
#include "indep_fixedform"
      DO 200 I=NMAX_01(2),NMAX
        J = ILIST(I) 
        RAD_SHRT_SNW_SAVE  (J,JL,1) = RAD_SHRT_SNW  (I,1)    
        RAD_SHRT_SNW_SAVE  (J,JL,2) = RAD_SHRT_SNW  (I,2)    
        R_STM_BAR_PAR_SNW_SAVE (J,JL,1) = R_STM_BAR_PAR_SNW (I,1) 
!       R_STM_BAR_PAR_SNW_SAVE (J,JL,2) = R_STM_BAR_PAR_SNW (I,2) 
!
  200 CONTINUE
!
      RETURN
      END
!  ���ˌv�Z�֘A�� SiB �p�̕ϐ����A�Z�[�u����B
!  99/05/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE RAD_RESTORE ( 
     I    NMAX                     , NMAX_01                   ,
     I    JL                       , ILIST                     , 
     I    RAD_SHRT_NOS_SAVE        , RAD_SHRT_SNW_SAVE         , 
     I    R_STM_BAR_PAR_NOS_SAVE   , R_STM_BAR_PAR_SNW_SAVE    , 
     O    RAD_SHRT_NOS             , RAD_SHRT_SNW              , 
     O    R_STM_BAR_PAR_NOS        , R_STM_BAR_PAR_SNW    )
!
! �T�v
!   ���ˌv�Z�֘A�� SiB �p�̕ϐ����A�Z�[�u����B
!   ���˂͎��ԊԈ������邪�ASiB �͖��X�e�b�v�v�Z���邽��
!
!   ��L���A�ᖳ����Ƃ�
!
! ����
!   RAD_CG �͂��̎��_�ł́A���ˊp�␳����Ȃ��Z�g���̂݁B
!
!
      USE PRM , ONLY : 
     1   IJPHY  , 
     1   JLPHY  , 
     1   ISPT 
!
      USE SIBPRM , ONLY :
     1   IDX    , 
     1   ICG 
!
      IMPLICIT NONE 
!
! INPUT
!
      REAL(8),INTENT(OUT)   ::  
     1        RAD_SHRT_SNW      ( IDX  , ICG ) , ! CG �ւ̒Z�g����
     1        RAD_SHRT_NOS      ( IDX  , ICG ) , ! CG �ւ̒Z�g����
     1        R_STM_BAR_PAR_SNW ( IDX  , ICG ) , ! �C�E��RPAR�ˑ�    
     1        R_STM_BAR_PAR_NOS ( IDX  , ICG )   ! �C�E��RPAR�ˑ�    
!
      INTEGER,INTENT(IN)   ::  JL
      INTEGER,INTENT(IN)   ::  NMAX_01(3)
      INTEGER,INTENT(IN)   ::  NMAX
      INTEGER,INTENT(IN)   ::  ILIST (IDX)  ! SiB -> PHYSCS 
!
! OUTPUT
!
      REAL(8),INTENT(IN)  ::  
     1     RAD_SHRT_SNW_SAVE      ( ISPT*IJPHY  , JLPHY , ICG )  ,  
     1     RAD_SHRT_NOS_SAVE      ( ISPT*IJPHY  , JLPHY , ICG )  , 
     1     R_STM_BAR_PAR_SNW_SAVE ( ISPT*IJPHY  , JLPHY , ICG )  , 
     1     R_STM_BAR_PAR_NOS_SAVE ( ISPT*IJPHY  , JLPHY , ICG )   
!
! WORK
!
      INTEGER              ::  I
      INTEGER              ::  J
!
      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'RAD_RESTORE 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 
!
!   ----------------------------------------
!!  >> �Z�g�v�Z�� �S�ʃf�[�^�ɃZ�[�u <<
!   ----------------------------------------
!
      DO 100 I=1,NMAX_01(3)
        J = ILIST(I) 
        R_STM_BAR_PAR_NOS (I,1) = R_STM_BAR_PAR_NOS_SAVE (J,JL,1) 
        R_STM_BAR_PAR_NOS (I,2) = R_STM_BAR_PAR_NOS_SAVE (J,JL,2) 
        RAD_SHRT_NOS      (I,1) = RAD_SHRT_NOS_SAVE      (J,JL,1) 
        RAD_SHRT_NOS      (I,2) = RAD_SHRT_NOS_SAVE      (J,JL,2) 
  100 CONTINUE
!
      DO 200 I=NMAX_01(2),NMAX
        J = ILIST(I) 
        R_STM_BAR_PAR_SNW (I,1) = R_STM_BAR_PAR_SNW_SAVE (J,JL,1) 
!       R_STM_BAR_PAR_SNW (I,2) = R_STM_BAR_PAR_SNW_SAVE (J,JL,2) 
        RAD_SHRT_SNW      (I,1) = RAD_SHRT_SNW_SAVE      (J,JL,1) 
        RAD_SHRT_SNW      (I,2) = RAD_SHRT_SNW_SAVE      (J,JL,2) 
  200 CONTINUE
!
      RETURN
      END