! forcing_read.F90 - (�ėp) ���n��f�[�^��1�����ǂݎ��
! vi: set sw=2 ts=72:

! forcing_locate_id �̏ڍ׃��b�Z�[�W�𓾂�ɂ�
! #define DEBUG_LOCATE
! �Ƃ���

! ���n��f�[�^�̓ǂݎ����s�����[�`���������Ɏ��߂�B
! �T�u���[�`���̓��[�U�����ږڂɂ�����̂���ɁA���ꂩ����p�������̂�
! ���ɂȂ�ׂĂ���B

!=======================================================================
! forcing_read_id - ���n��f�[�^�̎w�莞���ǂݎ�� (���}��)
!   ���n��f�[�^ cmark ����w�莞�� id �̃f�[�^��ǂݎ�� data �Ɋi�[����B
!   �w�莞���̃f�[�^���Ȃ���Γ��}���s�������ʂ� data �Ɋi�[����B
!   �G���[ (�w�莞���̑O��̃f�[�^��������Ȃ��ꍇ���܂�) ���ɂ�
!   data �ɂ� -999.0 ����������

subroutine forcing_read_id(cmark, data, id)
  use forcing, only: cur_file, IDIM, JDIM
  use date
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: id(5)
  real(8), intent(out):: data(IDIM, JDIM)
  integer:: ir1, ir2
  real(8):: weight

  call forcing_locate_id(cmark, id, ir1, ir2, weight)
  if (ir1 == 0) goto 9999
  if (ir2 == 0) goto 9999
  if (ir1 == ir2) then
    data(:, :) = cur_file%last%buf(:, :)
  else
    data = weight * cur_file%last%buf + (1.0 - weight) * cur_file%before%buf
  endif


#ifdef DEBUG
  if (associated(cur_file%maxmin_mask)) then
    print "(a4,' ',i4.4,4('-',i2.2),' max=',g16.6,' min=',g16.6)", &
      cmark, id, &
      maxval(data, mask=cur_file%maxmin_mask), &
      minval(data, mask=cur_file%maxmin_mask)
  endif
#endif
  return

  9999 continue
  data = -999.0_8
end subroutine

!=======================================================================
! forcing_read_nearest_id - ���n��f�[�^�̎w�莞���ǂݎ�� (���}��)
!   ���n��f�[�^ cmark ����w�莞�� id �̃f�[�^��ǂݎ�� data �Ɋi�[����B
!   �w�莞���̃f�[�^���Ȃ���΂����Ƃ��߂������̃f�[�^�� data �Ɋi�[����B
!   �����Ƃ��߂��Ƃ́Aweight �� halfpoint �𒴂����Ƃ��͌㎞�����Ƃ邱�ƁB
!   �G���[ (�w�莞���̑O��̃f�[�^��������Ȃ��ꍇ���܂�) ���ɂ�
!   data �ɂ� -999.0 ����������

subroutine forcing_read_nearest_id(cmark, data, id, halfpoint)
  use forcing, only: cur_file, IDIM, JDIM
  use date
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: id(5)
  real(8), intent(out):: data(IDIM, JDIM)
  real(8), intent(in):: halfpoint
  integer:: ir1, ir2
  real(8):: weight

  call forcing_locate_id(cmark, id, ir1, ir2, weight)
  if (ir1 == 0) goto 9999
  if (ir2 == 0) goto 9999
  if (ir1 == ir2) then
    data(:, :) = cur_file%last%buf(:, :)
  else if (weight >= halfpoint) then
    data(:, :) = cur_file%last%buf(:, :)
  else
    data(:, :) = cur_file%before%buf(:, :)
  endif

#ifdef DEBUG
  if (associated(cur_file%maxmin_mask)) then
    print "(a4,' ',i4.4,4('-',i2.2),' max=',g16.6,' min=',g16.6)", &
      cmark, id, &
      maxval(data, mask=cur_file%maxmin_mask), &
      minval(data, mask=cur_file%maxmin_mask)
  endif
#endif
  return

  9999 continue
  data = -999.0_8
end subroutine


!=======================================================================
! forcing_read_id2 - ���n��f�[�^�̎w�莞���ǂݎ�� (���Ԕ�)
!   ���n��f�[�^ cmark ����w�莞�� id �̑O��̃f�[�^���������B
!   ���O������ id1 �ɁA�f�[�^�� data1 �Ɋi�[����B
!   ���㎞���� id2 �ɁA�f�[�^�� data2 �Ɋi�[����B
!   �w�莞���̃f�[�^���Ȃ���Γ��}���s�������ʂ� data �Ɋi�[����B
!   ��������Z�o�����d�݂� weight �Ɋi�[����B�d�݂Ƃ�
!   (1.0 - weight) * data1 + weight * data2 ���w�莞�� id �̃f�[�^��
!   �^����悤�Ȃ��̂̂��Ƃł���B
!   �G���[ (�w�莞���̑O��̃f�[�^��������Ȃ��ꍇ���܂�) ���ɂ�
!   id1, id2 �ɂ͗��҂Ƃ��� 0 ���Adata1, data2 �ɂ� -999.0 ����������
!   

subroutine forcing_read_id2(cmark, id, id1, data1, id2, data2, weight, update)
  use forcing, only: forcing_select, cur_file, IDIM, JDIM
  use date
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: id(5)
  integer, intent(out):: id1(5)
  integer, intent(out):: id2(5)
  real, intent(out):: data1(IDIM, JDIM)
  real, intent(out):: data2(IDIM, JDIM)
  double precision, intent(out):: weight
  logical, intent(out):: update
  ! �L�^�ԍ�. 1, 2 �� before �o�b�t�@�� last �o�b�t�@���ɑΉ����A
  !  org �͒T���O�̒l�ł���B
  integer:: ir1, ir2, ir1org, ir2org

  call forcing_select(cmark)
  if (.not. associated(cur_file)) goto 9999
  ir1org = cur_file%before%irec
  ir2org = cur_file%last%irec
  call forcing_locate_id(cmark, id, ir1, ir2, weight)
  if (ir1 == 0) goto 9999
  if (ir2 == 0) goto 9999
  if (ir1 == ir2) then
    id1 = cur_file%last%id
    id2 = cur_file%last%id
    data1(:, :) = cur_file%last%buf(:, :)
    data2(:, :) = cur_file%last%buf(:, :)
  else
    id1 = cur_file%before%id
    id2 = cur_file%last%id
    data1(:, :) = cur_file%before%buf(:, :)
    data2(:, :) = cur_file%last%buf(:, :)
  endif
  update = ((ir1 /= ir1org) .or. (ir2 /= ir2org))
  return

  9999 continue
  id1 = 0
  id2 = 0
  data1 = -999.0
  data2 = -999.0
  weight = -1
  update = .FALSE.
end subroutine

!=======================================================================
! forcing_locate_id - ���n��f�[�^�̃t�@�C���ʒu�t��
!
!   ���n��f�[�^ cmark ����w�莞�� id �̑O��̃f�[�^���������B
!   ���O������^����L�^�̎����ԍ��� ir1 �Ɋi�[����B
!   ���㎞����^����L�^�̎����ԍ��� ir2 �Ɋi�[����B
!   �w�莞���̃f�[�^����`���}�ɂ���ė^���邽�߂̏d�݂� weight ��
!   �i�[����B�d�݂Ƃ�
!    (1.0 - weight) * data[ir1] + weight * data[ir2] ��
!   �w�莞�� id �̃f�[�^��^����悤�� weight �̂��Ƃł���B

subroutine forcing_locate_id(cmark, id, ir1, ir2, weight)
  use forcing, only: forcing_select, cur_file, &
    forcing_fetch
  use date
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: id(5)
  integer, intent(out):: ir1, ir2
  double precision, intent(out):: weight
  integer:: id_tmp(5), idiff_tmp(5)
  integer:: id_before(5), id_dif_data(5), id_dif_request(5)
  integer:: cmp
  integer:: irec_cycle_tail
  logical:: found
  double precision:: recno

#ifdef DEBUG_LOCATE
  write(6, "(a,i4.4,4('-',i2.2))") "#locate_id " // cmark, id
#endif
  if (cmark /= ' ') call forcing_select(cmark)
  !
  ! �v������ id_tmp ���Z�o
  !
  id_tmp(:) = id(:) + cur_file%id_offset(:)
  if (cur_file%cyclic) then
    call date_modulo(id_tmp, cur_file%id_start, cur_file%id_cycle)
  endif

  if (cur_file%form == 'GRADS') then
    ! GrADS �̏ꍇ ... ��Ԃ͂����邪 straightforward �Ɍv�Z�ł���
    call date_diff(id_tmp, cur_file%id_origin, idiff_tmp)
    call date_diff_div(idiff_tmp, cur_file%id_increment, recno)
    ir1 = floor(recno) + 1
    ir2 = ceiling(recno) + 1
    if (cur_file%cyclic) then
      id_tmp(:) = cur_file%id_origin(:) + (ir1 - 1) * cur_file%id_increment
      call date_compare(id_tmp, cur_file%id_start, cmp)
      if (cmp < 0) then
        call date_diff(id_tmp +cur_file%id_cycle, cur_file%id_origin, idiff_tmp)
        call date_diff_div(idiff_tmp, cur_file%id_increment, recno)
        ir1 = floor(recno) + 1
      endif
      id_tmp(:) = cur_file%id_origin(:) + (ir2 - 1) * cur_file%id_increment
      call date_compare(id_tmp, cur_file%id_start + cur_file%id_cycle, cmp)
      if (cmp > 0) then
        call date_diff(id_tmp -cur_file%id_cycle, cur_file%id_origin, idiff_tmp)
        call date_diff_div(idiff_tmp, cur_file%id_increment, recno)
        ir2 = ceiling(recno) + 1
      endif
    endif
  else if (cur_file%form == 'MABIKI') then
    ! Mabiki �̏ꍇ ... �L���b�V�������������A����Ă�����T��������
    ! ���L���b�V���̎����ɋ��܂�Ă���� found
    call date_in_cur_file(id_tmp, found)
    if (found) goto 1000

    ! Mabiki �̏ꍇ ... �L���b�V�������������A����Ă�����T��������
    irec_cycle_tail = 0
    ! last �̎� (�Ȃ���� 1) �̋L�^���珇�ɗv��������T��
    do
#ifdef DEBUG_LOCATE
      write(6, *) 'locate/MABIKI/first-loop', cur_file%last%irec
#endif
      call forcing_fetch(cmark, cur_file%last%irec + 1)
      irec_cycle_tail = cur_file%before%irec
      ! �t�@�C���I�[�܂��̓G���[��: �L�^#1������Ȃ���
      if (cur_file%last%irec == 0) exit
      ! �v������������ł���� found
      call date_in_cur_file(id_tmp, found)
      if (found) goto 1000
      ! �������v�������𒴂���悤�Ȃ� �L�^#1������Ȃ���
      call date_compare(cur_file%last%id, id_tmp, cmp)
      if (cmp > 0) exit
    enddo

    ! �L�^#1����v�����������ރf�[�^���������B
    cur_file%last%irec = 0  ! �����߂�
    if (.not. found) then
      do
#ifdef DEBUG_LOCATE
        write(6, *) 'locate/MABIKI/second-loop', cur_file%last%irec
#endif
        call forcing_fetch(cmark, cur_file%last%irec + 1)
        if (cur_file%last%irec == 0) exit
        call date_compare(cur_file%last%id, id_tmp, cmp)
        ! �v���������x���f�[�^���݂������Ƃ���ŒT����~
        if (cmp == 0) then
           ir1 = cur_file%last%irec
           goto 1100
        endif
        if (cmp > 0) then
          if (cur_file%cyclic .and. irec_cycle_tail > 0) then
            ir1 = irec_cycle_tail
            goto 1100
          endif
          if (cur_file%last%irec >= 2) goto 1000
        endif
        ! �v��������葁���f�[�^���Ȃ���� irec_cycle_tail ���g���̂���
        ! �����������_�ł��̏����͂��Ȃ��Ă��悭����B
        if (cmp < 0) then
          irec_cycle_tail = 0
        endif
      enddo
    endif

    print *, 'forcing_locate_id(', cmark, &
      '): file has insufficient data records'
    ir1 = 0
    ir2 = 0
    weight = -1.0
    return

    ! �����ɃW�����v���Ă�����L���b�V���̎������v������������ł���
    1000 continue
    ir1 = cur_file%before%irec
    1100 continue
    ir2 = cur_file%last%irec
  endif

  call forcing_fetch(cmark, ir1)
  call forcing_fetch(cmark, ir2)
  if (ir1 == ir2) then
    weight = 1.0
  else
    if (ir1 > ir2) then
      id_before = cur_file%before%id - cur_file%id_cycle
    else
      id_before = cur_file%before%id
    endif
    call date_diff(id_tmp, id_before, id_dif_request)
    call date_diff(cur_file%last%id, id_before, id_dif_data)
    call date_diff_div(id_dif_request, id_dif_data, weight)
  endif

#ifdef DEBUG_LOCATE
  write(6, *) "#locate_id return(", ir1, ir2, weight, ")"
#endif
end subroutine

!=======================================================================
! date_in_cur_file - cur_file �̃L���b�V���Ɏw�莞�������o����邩
!   �w�莞�� id �� cur_file �̃L���b�V���Ɍ��o�����ꍇ�^�� found �ɁB

subroutine date_in_cur_file(id, found)
  use forcing, only: cur_file
  use date
  implicit none
  integer, intent(in):: id(5)
  logical, intent(out):: found
  integer:: cmp_b, cmp_l
  if (cur_file%last%irec == 0 .or. cur_file%before%irec == 0) goto 9000
  if (.not. associated(cur_file%last%buf)) goto 9000
  if (.not. associated(cur_file%before%buf)) goto 9000
  call date_compare(id, cur_file%last%id, cmp_l)
  call date_compare(id, cur_file%before%id, cmp_b)
  found = cmp_l <= 0 .and. cmp_b >= 0
  return

  9000 continue
  found = .FALSE.
end subroutine

!=======================================================================
! forcing_read_cmark - ���n��f�[�^�̎w��v�f�ǂݎ��
!  forcing_open �ɂ���� cmark_f �Ƃ��ĊJ���ꂽ�t�@�C������
!  cmark �v�f�́u���̋L�^�v�� data �ɓǂݎ��B
!  cmark ����̏ꍇ�� cmark ���������Ȃ��B
!  �����ł��Ȃ���� last%buf ����|�C���^���� data �� -999.0 �Ŗ��߂�B

subroutine forcing_read_cmark(cmark_f, data, cmark)
  use forcing, only: cur_file, forcing_select, forcing_fetch, IDIM, JDIM
  implicit none
  character(len = 4), intent(in):: cmark_f, cmark
  real, intent(out):: data(IDIM, JDIM)
  integer:: irec
!
  call forcing_select(cmark_f)
  irec = cur_file%last%irec
  if (irec <= 0) irec = 1
  do
    call forcing_fetch(cmark_f, irec)
    if (cur_file%last%cmark == cmark) exit
    if (.not. associated(cur_file%last%buf)) then
      data = -999.0
      return
    endif
    if (cmark == ' ') exit
    irec = irec + 1
  enddo
  data = cur_file%last%buf
end subroutine

!=======================================================================
! forcing_swap - �o�b�t�@�̌���
!   �ǂݎ��o�b�t�@ last, before �̓��e����������B

subroutine forcing_swap
  use forcing, only: FORCING_RECORD, cur_file
  implicit none
  type(FORCING_RECORD):: tmp_buf
  tmp_buf = cur_file%last
  cur_file%last = cur_file%before
  cur_file%before = tmp_buf
end subroutine

!=======================================================================
! forcing_read_real - �����z��̒��ړǂݎ��
!
!   forcing_open �ɂ���ėv�f cmark ��^����Ƃ��ĊJ���ꂽ�t�@�C������A
!   abs(irec) �Ԗڂ̋L�^��ǂݎ������^�z�� data �Ɋi�[����B
!   �G���[���ɂ̓v���O��������~����B

subroutine forcing_read_real(cmark, irec, data)
  use forcing, only: cur_file, forcing_fetch, IDIM, JDIM
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: irec
  real, intent(out):: data(IDIM, JDIM)
  call forcing_fetch(cmark, abs(irec))
  if (.not. associated(cur_file)) then
    print *, 'cmark=<', cmark, '> not associated to file.'
    stop 
  endif
  if (cur_file%last%irec == 0) stop
  data(:, :) = cur_file%last%buf(:, :)
end subroutine

!=======================================================================
! forcing_read_int - �����z��̒��ړǂݎ��
!
!   forcing_open �ɂ���ėv�f cmark ��^����Ƃ��ĊJ���ꂽ�t�@�C������A
!   abs(irec) �Ԗڂ̋L�^��ǂݎ�萮���^�z�� data �Ɋi�[����B
!   �G���[���ɂ̓v���O��������~����B

subroutine forcing_read_int(cmark, irec, data)
  use forcing, only: cur_file, forcing_fetch, IDIM, JDIM
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: irec
  integer, intent(out):: data(IDIM, JDIM)
  call forcing_fetch(cmark, -abs(irec))
  if (.not. associated(cur_file)) then
    print *, 'cmark=<', cmark, '> not associated to file.'
    stop 
  endif
  if (cur_file%last%irec == 0) stop
  data(:, :) = cur_file%last%buf(:, :)
end subroutine

!=======================================================================
! forcing_fetch - ���n��f�[�^�̒��ړǂݎ��
!
!   forcing_open �ɂ���ėv�f cmark ��^����Ƃ��ĊJ���ꂽ�t�@�C������A
!   irec �Ԗڂ̋L�^��ǂݎ�� cur_file%last �Ɋi�[����B
!   irec �����̏ꍇ�͕������]�������^�ǂݎ����s���B
!   ������ cur_file%last �� cur_file%before �ɕۑ������B
!   ������ cur_file%before �͔p�������B
!   �G���[�܂��̓t�@�C���͈͊O�̏ꍇ�� cur_file%last%{irec, id} ��
!   �[���N���A���Acur_file%last%buf ����|�C���^������B
!   cmark �� cur_file%last%cmark �̐������͌������Ȃ��B

subroutine forcing_fetch(cmark, irec)
  use forcing, only: cur_file, forcing_select, IDIM, JDIM
  use date
  implicit none
  character(len = 4), intent(in):: cmark
  integer, intent(in):: irec
  integer, allocatable:: ibuf(:, :)
  character(len = 12):: access
  character(len = 4):: my_cmark
  integer:: my_id(5)
  integer:: ios, recno
  ios = 0
  call forcing_select(cmark)

  if (.not. associated(cur_file)) goto 9000

  ! �o�b�t�@�����O�ŕۑ��������̂��Ђ�������Ƃ��ꂵ��
  if (cur_file%last%irec == irec) then
    return
  else if (cur_file%before%irec == irec) then
    ! before �� last ������
    call forcing_swap
    return
  endif

  ! before ��p���� last �� before �ɕۑ�
  if (associated(cur_file%before%buf)) deallocate(cur_file%before%buf)
  cur_file%before = cur_file%last
  ! last �̒l������
  cur_file%last%irec = irec
  recno = abs(irec)
  allocate(cur_file%last%buf(IDIM, JDIM))

  if (cur_file%form == 'MABIKI') then
    if (irec < 0) then
      allocate(ibuf(IDIM, JDIM))
      read(unit=cur_file%unit, rec=recno, iostat=ios) &
        cur_file%last%cmark, cur_file%last%id(1: 4), ibuf
      cur_file%last%buf = real(ibuf)
      deallocate(ibuf)
    else
      read(unit=cur_file%unit, rec=recno, iostat=ios) &
        my_cmark, my_id(1: 4), cur_file%last%buf
      cur_file%last%cmark = my_cmark
      cur_file%last%id = my_id
    endif
    cur_file%last%id(5) = 0
  else if (cur_file%form == 'GRADS') then
    recno = (recno - 1) * cur_file%varlevs + cur_file%levoffset
    read(unit=cur_file%unit, rec=recno, iostat=ios) &
      cur_file%last%buf
    cur_file%last%cmark = cmark
    cur_file%last%id = cur_file%id_origin &
      + cur_file%id_increment * (cur_file%last%irec - 1)
  endif

  ! �ǂݎ��Ɏ��s������
  if (ios /= 0) then
    inquire(unit=cur_file%unit, access=access)
    print *, 'read error = ', ios, cur_file%unit, recno, access
    if (ios == 443) print *, ' may caused by missing -Fport"(stduf)"'
    goto 9000
  endif

#ifdef DEBUG
  if (associated(cur_file%maxmin_mask)) then
    print "(a4,' record=',i8,' max=',g16.6,' min=',g16.6)", &
      cmark, irec, &
      maxval(cur_file%last%buf, mask=cur_file%maxmin_mask), &
      minval(cur_file%last%buf, mask=cur_file%maxmin_mask)
  endif
#endif

  call date_normalize(cur_file%last%id)
  return

  ! �G���[���I������
  9000 continue
  cur_file%last%irec = 0
  cur_file%last%id(:) = 0
  cur_file%last%cmark = '!err'
  if (associated(cur_file%last%buf)) deallocate(cur_file%last%buf)
end subroutine