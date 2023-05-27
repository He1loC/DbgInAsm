.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive
	
	include debugger.Inc
	
	
	
	
	
	
.const
	g_szDumpFile db "MyDump.exe",0
	g_szEXCEPTION_DEBUG_EVENT      db "EXCEPTION_DEBUG_EVENT",0
	g_szCREATE_THREAD_DEBUG_EVENT  db "CREATE_THREAD_DEBUG_EVENT",0
	g_szCREATE_PROCESS_DEBUG_EVENT db "CREATE_PROCESS_DEBUG_EVENT ",0
	g_szEXIT_THREAD_DEBUG_EVENT    db "EXIT_THREAD_DEBUG_EVENT",0
	g_szEXIT_PROCESS_DEBUG_EVENT   db "EXIT_PROCESS_DEBUG_EVENT",0
	g_szLOAD_DLL_DEBUG_EVENT       db "LOAD_DLL_DEBUG_EVENT",0
	g_szUNLOAD_DLL_DEBUG_EVENT     db "UNLOAD_DLL_DEBUG_EVENT",0
	g_szOUTPUT_DEBUG_STRING_EVENT  db "OUTPUT_DEBUG_STRING_EVENT",0
	
	g_szCommandErrTip              db "命令出错", 0dh, 0ah, 0
	g_szSysBpTip                   db "到达系统断点", 0dh, 0ah, 0
	g_szBpTip                   db "命中一般断点 %08X", 0dh, 0ah, 0
	g_szBhTip                      db "命中硬件断点 %08X", 0dh, 0ah, 0
	g_szBMReadTip                      db "命中内存断点 读取 [%08X]", 0dh, 0ah, 0
	g_szBMWriteTip                      db "命中内存断点 写入 [%08X]", 0dh, 0ah, 0
	g_szBMAccessTip                    db "命中内存断点 访问 [%08X]", 0dh, 0ah, 0 
	g_szErrorBpNotFoundInTable                   db "断点未在表中找到，致命错误", 0dh, 0ah, 0
	g_szThereIsNoBpTip                   db "没有断点，请下断点", 0dh, 0ah, 0
	g_szThereIsNoBMBpTip                   db "没有内存断点，请下断点", 0dh, 0ah, 0
	g_szHardWareBpFullTip               db "硬件断点已满，请删除断点bch ID", 0dh, 0ah, 0      
	
	g_szTableHead              db "序号",09h,"地址",09h,09h,"原字节",09h,"类型",0dh, 0ah, 0
	g_szBHTableHead              db "序号",09h,"地址",09h,09h,"长度",09h,"类型",0dh, 0ah, 0
	g_szBMTableHead              db "序号",09h,"地址",09h,09h,"长度",09h,09h,"类型",0dh, 0ah, 0
	g_szBMIDPageTableHead   db "序号",09h,"页地址",0dh, 0ah, 0
	g_szTypeNormal         db "一般",0
	g_szByte                     db "BYTE",0
	g_szWord                     db "WORD",0
	g_szDWord                     db "DWORD",0
	g_szExecute                     db "硬件执行",0
	g_szWrite                    db "硬件写入",0
	g_szAccess                     db "硬件访问",0
	g_szBMWrite                    db "内存写入",0
	g_szBMAccess                     db "内存访问",0
	g_szBMPageFault         db "目标范围内缺页，请重新设置断点",0dh, 0ah, 0
	
	g_szFmt                        db "%s",0dh, 0ah, 0
	g_szScpFmt                        db "%s",0ah, 0
	g_szTraceFmt                    db "%08X %s", 0dh, 0ah, 0
	g_szLoadDllFmt                 db "%08X %s", 0dh, 0ah, 0
	g_szOutputDBGStrFmt                 db "DBG:%s", 0dh, 0ah, 0
	g_szPrintBpFmt                        db "%04d",09h,"%p",09h,"%02X",09h,"%s",0dh, 0ah, 0
	g_szPrintBHFmt                        db "%04d",09h,"%p",09h,"%s",09h,"%s",0dh, 0ah, 0
	g_szPrintBMFmt                        db "%04d",09h,"%p",09h,"%p",09h,"%s",0dh, 0ah, 0
	g_szPrintBMIDPageFmt                        db "%04d",09h,"%p",0dh, 0ah, 0
	g_szDisasmFmt                       db "%p    %s",0dh, 0ah, 0
	g_szNotUsedFmt                     db "%04d",09h,"未使用",0dh, 0ah, 0
	g_szBMOverlappedFmt               db "内存断点与%d号断点重合,请重新设置", 0dh, 0ah, 0
	g_szPromptUserInput              db ">>:",0
	g_szModuleListFmt                  db "%08x %s",0dh, 0ah, 0
	g_szAllRegsFmt                db "EAX=%08X EBX=%08X ECX=%08X EDX=%08X",0dh,0ah
	                                                db "ESI=%08X EDI=%08X ESP=%08X EBP=%08X",0dh,0ah
	                                                db "GS=%04X FS=%04X CS=%04X DS=%04X ES=%04X SS=%04X EIP=%08X",0dh,0ah
	                                                db "EFLAGS=%08X",0dh,0ah
	                                                db "CF=%01d PF=%01d AF=%01d ZF=%01d SF=%01d TF=%01d IF=%01d DF=%01d OF=%01d ",0dh,0ah,0   
	                                                
	
	g_szCall    db "call", 0
.data
	g_szFileName db 512 dup(0)
	g_dwImageBase DWORD 0
	g_dwOEP DWORD 0
	
	g_szGo   db "g",0dh,0ah,0
	
	g_bIsLastTimeDisasm DWORD FALSE ;最后一次命令是否是反汇编
	g_dwAddrToContinueDisasm    DWORD 0 ;继续反汇编的指令地址
	
	g_bIsLastTimeDD       DWORD  FALSE ;最后一次命令是否是DD显示内存
	g_dwAddrToContinueDD    DWORD 0 ;继续反汇编的内存地址
	
	g_de        DEBUG_EVENT <0>
	g_hProc     HANDLE 0
	g_szCommand db 256 dup(0)
	
	g_byteOld  byte 0               ;保存原有指令的首字节
	g_byteCC   byte 0CCh          ;0xCC
	
	g_bIsSysBp byte TRUE        ;指明是否为系统断点
	g_dwLastBpAddr  DWORD 0
	g_dwLastHardWareBpAddr  DWORD 0
	
	
	g_arrayNormalBps tagNormalBp 500 dup(<0>)            ;软件断点-最多500个断点
	g_arrayNormalBpsLength dw $-g_arrayNormalBps      
	g_nNumOfCurNormalBp  DWORD 0         ;当前断点个数
	
	g_arrayStepOverBps tagStepOverBp 500 dup(<0>)            ;步过设置的断点，最多500个步过断点
	g_arrayStepOverBpsLength dw $-g_arrayStepOverBps      
	g_nNumOfCurStepOverBp  DWORD 0         ;当前断点个数
	
	g_arrayHardwareBps tagHardwareBp 4 dup(<0>)	;硬件断点
	g_nNumOfCurHardwareBp  DWORD 0      ;当前硬件断点个数
	
	
	g_nCurAvailableID   DWORD 0                            ;当前可用ID
	g_tableBMBps tagMemBp 500 dup(<0>)            ;内存访问断点表
	g_tableBMBpsLenth dw $ - g_tableBMBps
	g_nNumOfCurBMBps DWORD	0
	
	g_tableBMIDPage tagBMIDPage 500  dup(<0>)      ;ID - 分页表
	g_tableBMIDPageLenth dw $ - g_tableBMIDPage
	g_nNumOfCurBMIDPage DWORD	0
	
	g_tableBMPage tagBMPage 500  dup(<0>)      ;分页表
	g_tableBMPageLenth dw $ - g_tableBMPage
	g_nNumOfCurBMPage DWORD	0
	
	
	g_bIsNormallBpSingleStep DWORD FALSE ;
	g_bIsStepIntoSingleStep  DWORD FALSE       ;是否是步入命令
	g_bIsHardwareBpSingleStep DWORD FALSE ;标志硬件断点为了恢复引发的单步
	g_dwDR6LToRestore  DWORD 0
	g_bIsMemBpSingleStep  DWORD FALSE   ;标志是为恢复内存断点设置的单步
	g_dwLastPageAddr  DWORD 0                  ;命中内存断点后，记录本次的页地址，用于在单步中恢复
	
	
	g_bIsTraceOn        DWORD FALSE
	g_dwTraceDstAddr  DWORD 0
	g_pTraceFile            DWORD 0
	
	g_bIsGoRet        DWORD FALSE
	
	
	g_szLoadScpName   BYTE  256 dup(0)
	g_pLoadScpFile  DWORD 0
	g_bIsScpLoaded DWORD FALSE
	
	g_arrSzCmds     BYTE 256*100 dup(0)
	g_nTotalCmds    DWORD 0
	g_bIsRecording  DWORD TRUE
.code
ExportScript proc uses ecx esi pFile:DWORD
    
    xor ecx,ecx
    mov esi,offset g_arrSzCmds
    .WHILE  ecx < g_nTotalCmds
        push ecx
        invoke crt_fprintf,pFile,offset g_szScpFmt,esi
        pop ecx
        add esi,256
        inc ecx
    .ENDW
    
    invoke crt_fclose,pFile
    
    ret

ExportScript endp


JudgeIsRetReached proc
LOCAL @szBufAsm[64]:BYTE
LOCAL @dwEip:DWORD
LOCAL @dwBytesReadWrite:DWORD
LOCAL @dwCodeLen:DWORD
LOCAL @bufCode[16]:BYTE

        invoke RtlZeroMemory, addr @szBufAsm, 64
	
	;反汇编
	invoke GetEip
	mov @dwEip, eax
	
	invoke ReadProcessMemory, g_hProc, @dwEip, addr @bufCode, 16, addr @dwBytesReadWrite
	;此时反汇编处如果有CC断点，要看看先能不能复原
	invoke DisasmLineEx, addr @bufCode, 16, @dwEip, addr @szBufAsm
	mov @dwCodeLen, eax    
	
	fn crt_strstr, addr @szBufAsm, "ret"
	.IF eax
	    mov eax,TRUE
	.ELSE
	    mov eax,FALSE
	.endif
    
        ret

JudgeIsRetReached endp



SetGoRet proc
    invoke SetTraceOver
    
    mov g_bIsGoRet,TRUE
    
    ret

SetGoRet endp


SetTraceOver proc
LOCAL @szBufAsm[64]:BYTE
LOCAL @dwEip:DWORD
LOCAL @dwBytesReadWrite:DWORD
LOCAL @dwCodeLen:DWORD
LOCAL @bufCode[16]:BYTE
LOCAL @dwCurPBpAddr:DWORD
LOCAL @byteOld:DWORD

        invoke RtlZeroMemory, addr @szBufAsm, 64
	
	;反汇编
	invoke GetEip
	mov @dwEip, eax
	
	invoke ReadProcessMemory, g_hProc, @dwEip, addr @bufCode, 16, addr @dwBytesReadWrite
	;此时反汇编处如果有CC断点，要看看先能不能复原
	invoke DisasmLineEx, addr @bufCode, 16, @dwEip, addr @szBufAsm
	mov @dwCodeLen, eax
    
        invoke crt_strstr, addr @szBufAsm, offset g_szCall
			.IF eax == NULL
				;不是call指令,与步入一致
				invoke SetTF
				ret
			.else 
				;call指令, 在下一条指令设置断点
				mov eax, @dwEip
				add eax, @dwCodeLen
				mov @dwCurPBpAddr, eax
				invoke SetBp, @dwCurPBpAddr
				mov @byteOld,eax
				;保存断点到断点表
				invoke SaveStepOverBpToTable,@byteOld,@dwCurPBpAddr
			.endif
    
    ret

SetTraceOver endp



SetStepOver proc
LOCAL @szBufAsm[64]:BYTE
LOCAL @dwEip:DWORD
LOCAL @dwBytesReadWrite:DWORD
LOCAL @dwCodeLen:DWORD
LOCAL @bufCode[16]:BYTE
LOCAL @dwCurPBpAddr:DWORD
LOCAL @byteOld:DWORD

        invoke RtlZeroMemory, addr @szBufAsm, 64
	
	;反汇编
	invoke GetEip
	mov @dwEip, eax
	
	invoke ReadProcessMemory, g_hProc, @dwEip, addr @bufCode, 16, addr @dwBytesReadWrite
	;此时反汇编处如果有CC断点，要看看先能不能复原
	invoke DisasmLineEx, addr @bufCode, 16, @dwEip, addr @szBufAsm
	mov @dwCodeLen, eax
    
        invoke crt_strstr, addr @szBufAsm, offset g_szCall
			.IF eax == NULL
				;不是call指令,与步入一致
				invoke SetTF
				mov g_bIsStepIntoSingleStep,TRUE
				ret
			.else 
				;call指令, 在下一条指令设置断点
				mov eax, @dwEip
				add eax, @dwCodeLen
				mov @dwCurPBpAddr, eax
				invoke SetBp, @dwCurPBpAddr
				mov @byteOld,eax
				;保存断点到断点表
				invoke SaveStepOverBpToTable,@byteOld,@dwCurPBpAddr
			.endif
    
    ret

SetStepOver endp


SetTrace proc dwAddr:DWORD
    
    invoke SetTF
    
    mov g_bIsTraceOn,TRUE
    mov eax,dwAddr
    mov g_dwTraceDstAddr,eax
    
    ;创建文件
    fn crt_fopen,"TraceFile.log","w"
    mov g_pTraceFile,eax
    
    
    
    ret

SetTrace endp


GetApiNameFromDll proc uses esi edi ecx hDll:HMODULE,dwAddr:DWORD,szAPIName:PSTR
LOCAL @DosHdr:IMAGE_DOS_HEADER
LOCAL @NTHdr:IMAGE_NT_HEADERS
LOCAL  @dwNumOfBytesWritten:DWORD
LOCAL @pSectionTable:ptr IMAGE_SECTION_HEADER
LOCAL @pExportDir:ptr IMAGE_EXPORT_DIRECTORY
LOCAL @ExportDir:IMAGE_EXPORT_DIRECTORY
LOCAL @pFuntionsTable:DWORD
LOCAL @pNamesTable:DWORD
LOCAL @pNameOrdinalsTable:DWORD
LOCAL @dwExportDirSize:DWORD
LOCAL @dwAPIRVA:DWORD
LOCAL @dwNumOfFunctions:DWORD
LOCAL @dwNumOfNames:DWORD
LOCAL @dwCurOrdinal:DWORD ;当前序号
LOCAL @dwAPIOrdinal:DWORD ;查找API的序号
LOCAL @dwCurRVA:DWORD      ;当前RVA
LOCAL @dwAPINamesOrdinalTableIdx:DWORD   
LOCAL @dwAPINameRVA:DWORD
LOCAL @szAPIBuf[MAX_PATH]:BYTE
        
        ;此刻本地有：DOS头、NT头、导出表(没有另外三张表)

        ;读dos头 
	invoke ReadProcessMemory,g_hProc,hDll,addr @DosHdr,sizeof @DosHdr,addr @dwNumOfBytesWritten
	
	;读NT头,拿到导出表的RVA->VA和SIZE
	mov ebx,@DosHdr.e_lfanew
	add ebx,hDll
	invoke ReadProcessMemory,g_hProc,ebx,addr @NTHdr,sizeof @NTHdr,addr @dwNumOfBytesWritten
	.iF @NTHdr.OptionalHeader.DataDirectory[0].VirtualAddress == 0
	    RET
	.endif
	
	mov eax,@NTHdr.OptionalHeader.DataDirectory[0].VirtualAddress
	add eax,hDll
	mov @pExportDir,eax
	mov eax,@NTHdr.OptionalHeader.DataDirectory[0].isize
	mov @dwExportDirSize,eax
	
	;读导出表
	invoke ReadProcessMemory,g_hProc,@pExportDir,addr @ExportDir,sizeof @ExportDir,addr @dwNumOfBytesWritten
	
	;计算API的RVA,用于后面的查找
	mov eax,dwAddr
	sub eax,hDll
	mov @dwAPIRVA,eax
        
        ;导出函数个数
        mov eax,@ExportDir.NumberOfFunctions
        mov @dwNumOfFunctions,eax
        
        ;以名称导出的函数个数
        mov eax,@ExportDir.NumberOfNames
        mov @dwNumOfNames,eax
        
        ;获取三张表的VA，方便后面读取
        mov eax,@ExportDir.AddressOfFunctions
        add eax,hDll
        mov @pFuntionsTable,eax
        mov eax,@ExportDir.AddressOfNames
        add eax,hDll
        mov @pNamesTable,eax
        mov eax,@ExportDir.AddressOfNameOrdinals
        add eax,hDll
        mov @pNameOrdinalsTable,eax
       
        ;比较导出地址表中的RVA
        mov @dwAPIOrdinal,0
        xor ecx,ecx ;注意ECX被修改的情况
        .while ecx < @dwNumOfFunctions
            mov esi,@pFuntionsTable
            lea  esi,[esi+ecx*4]
            
            push ecx
            invoke ReadProcessMemory,g_hProc,esi,addr @dwCurRVA,sizeof @dwCurRVA,addr @dwNumOfBytesWritten
            pop ecx
            
            mov eax,@dwAPIRVA
            .IF  @dwCurRVA ==  eax
                .BREAK
            .ENDIF          
            
            inc @dwAPIOrdinal
            inc ecx
        .endw
        
        
        .IF ecx == @dwNumOfFunctions
            ret
        .ENDIF
        
        ;比较名字序号表, 注意：序号是WORD
        mov @dwAPINamesOrdinalTableIdx,0
        xor ecx,ecx ;注意ECX被修改的情况
        .while ecx < @dwNumOfNames
            mov esi,@pNameOrdinalsTable
            lea  esi,[esi+ecx*2]
            
            
            mov @dwCurOrdinal,0
            push ecx
            invoke ReadProcessMemory,g_hProc,esi,addr @dwCurOrdinal,sizeof WORD,addr @dwNumOfBytesWritten   
            pop ecx
            
            mov eax,@dwAPIOrdinal
            .IF  @dwCurOrdinal ==  eax
                .BREAK
            .ENDIF          
            
            inc @dwAPINamesOrdinalTableIdx
            inc ecx
        .endw
        
        .IF ecx == @dwNumOfNames        ;序号导出,TODO
            mov esi,@ExportDir.nBase
            add esi,@dwAPIOrdinal
            
            fn crt_sprintf,szAPIName,"#%04X",esi
            ret
        .ENDIF
        
	;名字导出
	mov esi,@pNamesTable
	mov ecx,@dwAPINamesOrdinalTableIdx
	lea esi,[esi+ecx*4]
	
	invoke ReadProcessMemory,g_hProc,esi,addr @dwAPINameRVA,sizeof @dwAPINameRVA,addr @dwNumOfBytesWritten   
	
	mov esi,@dwAPINameRVA
	add esi,hDll
	
	invoke ReadProcessMemory,g_hProc,esi,addr @szAPIBuf,sizeof @szAPIBuf,addr @dwNumOfBytesWritten   
	
	
	invoke crt_strcpy,szAPIName,addr @szAPIBuf
	

        ret
GetApiNameFromDll endp



GetAPINameByAddr proc uses esi edi dwAddr:DWORD,szAPIName:PSTR
LOCAL @hMods[1024]:HMODULE
LOCAL @cbNeeded:DWORD
LOCAL @dwNumOfMods:DWORD
LOCAL @szModName[MAX_PATH]:BYTE
LOCAL @mi:MODULEINFO
LOCAL @szAPIBuf[MAX_PATH]:BYTE
    
    ;遍历所有模块
    invoke EnumProcessModules,g_hProc,addr @hMods,sizeof @hMods,addr @cbNeeded
	.IF eax == 0
		ret
	.endif   
	
    mov eax,@cbNeeded
	shr eax,2
	mov @dwNumOfMods,eax
	
	xor esi,esi
	
	;判断落在哪个模块中
	.WHILE esi < @dwNumOfMods
	        invoke RtlZeroMemory,addr @mi,sizeof @mi
	        invoke GetModuleInformation,g_hProc,@hMods[esi*4],addr @mi,sizeof @mi
		
		mov edi,@hMods[esi*4]
		add edi,@mi.SizeOfImage
		mov eax,dwAddr
		.IF eax>= @hMods[esi*4] && eax < edi
		    invoke GetModuleBaseName,g_hProc,@hMods[esi*4],addr @szModName,sizeof @szModName
		    
		    fn crt_strstr,addr @szModName,"."
		    .IF eax!=0
		        mov byte ptr [eax],0
		    .endif
		    
		    invoke RtlZeroMemory,addr @szAPIBuf,sizeof @szAPIBuf
		    invoke GetApiNameFromDll,@hMods[esi*4],dwAddr,addr @szAPIBuf
		    
		    mov al,@szAPIBuf[0]
		    
		    .IF al == 0
		        fn crt_sprintf,szAPIName,"<&%s.%p>",addr @szModName,dwAddr
		    .ELSE
		         fn crt_sprintf,szAPIName,"<&%s.%s>",addr @szModName,addr @szAPIBuf   
		    .endif
		    
		    
		    ret
		.ENDIF
		
		inc esi
	.endw
    
    
    ret

GetAPINameByAddr endp


;修改指定地址的一个字节
EditDataAtAddr proc uses esi dwAddr:DWORD,dwVal:DWORD
LOCAL @bData:BYTE
LOCAL @dwCurAddr:DWORD
LOCAL @dwBytesReadWrite:DWORD

	mov eax,dwAddr
	mov @dwCurAddr,eax
        ;读入该字节
        invoke ReadProcessMemory, g_hProc, @dwCurAddr, addr @bData, 1, addr @dwBytesReadWrite 
        
        ;检查是否为0xCC,如果是,检查是否为断点,如果是断点，在断点表里改写即可.
        movzx eax,  @bData  
	  .IF al == 0CCh
	        invoke GetNormalBpAddrInTable,@dwCurAddr
		.IF eax != 0
			mov esi,eax
			assume esi:ptr tagNormalBp
			mov eax,dwVal
			mov [esi].m_byteOld,al
		.ELSE
			invoke GetStepOverBpAddrInTable,@dwCurAddr
			.IF eax != 0
				mov esi,eax
				assume esi:ptr tagStepOverBp
				mov eax,dwVal
			        mov [esi].m_byteOld,al
			.endif
		.endif
	.ELSE
	    mov eax,dwVal
	    mov @bData,al
	    invoke WriteProcessMemory,g_hProc,dwAddr,addr @bData,size @bData,addr @dwBytesReadWrite
	    .IF eax == 0
	        fn crt_puts,LastError$()
	    .endif
	    .endif
    
    ret

EditDataAtAddr endp



DispDataOneLine proc uses esi edi  dwAddr:DWORD
LOCAL @bDatas[16]:BYTE
LOCAL @nIdx:DWORD
LOCAL @dwCurAddr:DWORD
LOCAL @dwBytesReadWrite:DWORD

        mov @nIdx,0
	mov eax,dwAddr
	mov @dwCurAddr,eax
        ;读入一行的数量
        invoke ReadProcessMemory, g_hProc, @dwCurAddr, addr @bDatas, 16, addr @dwBytesReadWrite  
        
        fn crt_printf,"%p ",dwAddr
	
	xor edi,edi
	.WHILE edi<16
	    ;检查是否为0xCC,如果是,检查是否为断点
	    mov al,byte ptr @bDatas[edi]
	    .IF al == 0CCh
	        invoke GetNormalBpAddrInTable,@dwCurAddr
		.IF eax != 0
			mov esi,eax
			assume esi:ptr tagNormalBp
			mov al,[esi].m_byteOld
			mov byte ptr @bDatas[edi],al
		.ELSE
			invoke GetStepOverBpAddrInTable,@dwCurAddr
			.IF eax != 0
				mov esi,eax
				assume esi:ptr tagStepOverBp
				mov al,[esi].m_byteOld
				mov byte ptr @bDatas[edi],al
			.endif
		.endif
	    .endif
	    
	    movzx eax,byte ptr @bDatas[edi]
	    fn crt_printf,"%02X ",eax
	    
	    inc @dwCurAddr
	    inc edi
	.ENDW
	
	xor edi,edi
	.WHILE edi<16
	    movzx eax,byte ptr @bDatas[edi]
	    
	    invoke crt_isprint,eax
	    .IF eax
	        movzx eax,byte ptr @bDatas[edi]
	        invoke crt_putchar,eax
	    .ELSE
	         invoke crt_putchar,'.'
	    .endif
	    
	    
    	    inc edi
	.ENDW
	
	
        fn crt_puts," "	  
    
    ret

DispDataOneLine endp


DispData8Lines proc dwStartAddr:DWORD
LOCAL @nIdx:DWORD
LOCAL @dwCurAddr:DWORD
	
	mov @nIdx,0
	mov eax,dwStartAddr
	mov @dwCurAddr,eax
	
	.WHILE @nIdx<8
		invoke DispDataOneLine,@dwCurAddr
		add @dwCurAddr,16
		inc @nIdx
	.endw    
    
    mov eax,@dwCurAddr
    ret

DispData8Lines endp



SetRegVal proc szReg:PSTR,dwVal:DWORD
LOCAL @hThread:HANDLE
LOCAL @ctx:CONTEXT

    invoke RtlZeroMemory,addr @ctx,sizeof @ctx
    invoke GetContext,addr @ctx
    
    fn lstrcmpi,szReg,"eax"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEax,eax
        jmp LB_SET_OK
    .endif
    
    fn lstrcmpi,szReg,"ebx"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEbx,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"ecx"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEcx,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"edx"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEdx,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"esp"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEsp,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"ebp"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEbp,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"esi"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEsi,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"edi"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEdi,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"eip"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEip,eax
        jmp LB_SET_OK
    .endif
    
     fn lstrcmpi,szReg,"eflags"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regFlag,eax
        jmp LB_SET_OK
    .endif
   
   fn lstrcmpi,szReg,"gs"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regGs,eax
        jmp LB_SET_OK
    .endif
    
    fn lstrcmpi,szReg,"fs"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regFs,eax
        jmp LB_SET_OK
    .endif
    
    fn lstrcmpi,szReg,"Cs"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regCs,eax
        jmp LB_SET_OK
    .endif
    
    fn lstrcmpi,szReg,"Ds"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regDs,eax
        jmp LB_SET_OK
    .endif
    
    fn lstrcmpi,szReg,"Es"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regEs,eax
        jmp LB_SET_OK
    .endif
    
    fn lstrcmpi,szReg,"Ss"
    .IF eax == 0
        mov eax,dwVal
        mov @ctx.regSs,eax
        jmp LB_SET_OK
    .endif
    
        mov eax,FALSE
        ret      

    
LB_SET_OK:
	invoke SetContext,addr @ctx
	mov eax,TRUE
	ret

SetRegVal endp



ShowAllRegs proc
LOCAL @ctx:CONTEXT
LOCAL @hThread:HANDLE
LOCAL @dwCF:DWORD
LOCAL @dwPF:DWORD
LOCAL @dwAF:DWORD
LOCAL @dwZF:DWORD
LOCAL @dwSF:DWORD
LOCAL @dwTF:DWORD
LOCAL @dwIF:DWORD
LOCAL @dwDF:DWORD
LOCAL @dwOF:DWORD
	
	invoke RtlZeroMemory, addr @ctx, size @ctx

	invoke GetContext,addr @ctx
	
	mov @dwCF,0
	.IF @ctx.regFlag & 0000000000000001b
	    mov @dwCF,1
	.ENDIF
	
	mov @dwPF,0
	.IF @ctx.regFlag & 0000000000000100b
	    mov @dwPF,1
	.ENDIF
	
	mov @dwAF,0
	.IF @ctx.regFlag & 0000000000010000b
	    mov @dwAF,1
	.ENDIF
	
	mov @dwZF,0
	.IF @ctx.regFlag & 0000000001000000b
	    mov @dwZF,1
	.ENDIF
	
	mov @dwSF,0
	.IF @ctx.regFlag & 0000000010000000b
	    mov @dwSF,1
	.ENDIF
	
	mov @dwTF,0
	.IF @ctx.regFlag & 0000000100000000b
	    mov @dwTF,1
	.ENDIF
	
	mov @dwIF,0
	.IF @ctx.regFlag & 0000001000000000b
	    mov @dwIF,1
	.ENDIF
	
	mov @dwDF,0
	.IF @ctx.regFlag & 0000010000000000b
	    mov @dwDF,1
	.ENDIF
	
	mov @dwOF,0
	.IF @ctx.regFlag & 0000100000000000b
	    mov @dwOF,1
	.ENDIF
	
	
	
	
	invoke crt_printf,offset g_szAllRegsFmt,@ctx.regEax,@ctx.regEbx,@ctx.regEcx,@ctx.regEdx, \
	                                                                    @ctx.regEsi,@ctx.regEdi,@ctx.regEsp,@ctx.regEbp,@ctx.regGs,\
	                                                                    @ctx.regFs,@ctx.regCs,@ctx.regDs,@ctx.regEs,@ctx.regSs,@ctx.regEip, @ctx.regFlag, \
	                                                                    @dwCF,@dwPF,@dwCF,@dwAF,@dwZF,@dwSF,@dwTF,@dwIF,@dwDF,@dwOF
	
	
	
	ret
    
    
    

ShowAllRegs endp

	
ListAllModules proc uses esi
LOCAL @hMods[1024]:HMODULE
LOCAL @cbNeeded:DWORD
LOCAL @dwNumOfMods:DWORD
LOCAL @szModName[MAX_PATH]:BYTE
	
	invoke EnumProcessModules,g_hProc,addr @hMods,sizeof @hMods,addr @cbNeeded
	.IF eax == 0
		ret
	.endif
	
	mov eax,@cbNeeded
	shr eax,2
	mov @dwNumOfMods,eax
	
	xor esi,esi
	
	.WHILE esi < @dwNumOfMods
		invoke RtlZeroMemory,addr @szModName,sizeof @szModName
		
		invoke GetModuleFileNameEx,g_hProc,@hMods[esi*4],addr @szModName,sizeof @szModName
		.IF eax != 0
			invoke crt_printf,offset g_szModuleListFmt,@hMods[esi*4],addr @szModName
		.endif
		
		
		inc esi
	.endw
	
	
	
	
	
	ret
	
ListAllModules endp
	
	
RestorAllCCBps proc uses esi edi
LOCAL @byteOld:BYTE
LOCAL @nNumOfBytesWritten:DWORD
	
	;0xcc断点有两种 一般断点表  和 临时/单步断点表
	;还原一般断点表
	assume esi:ptr tagNormalBp
	mov esi,offset g_arrayNormalBps
	xor edi,edi
	.while edi < g_nNumOfCurNormalBp
		movzx eax,[esi].m_byteOld
		mov @byteOld,al
		invoke WriteProcessMemory,g_hProc,[esi].m_dwAddr,addr @byteOld,size @byteOld,addr @nNumOfBytesWritten
		inc  edi
		add esi,sizeof tagNormalBp
	.endw  
	
	;还原单步断点表
	assume esi:ptr tagStepOverBp
	mov esi,offset g_arrayStepOverBps
	xor edi,edi
	.while edi < g_nNumOfCurStepOverBp
		movzx eax,[esi].m_byteOld
		mov @byteOld,al
		invoke WriteProcessMemory,g_hProc,[esi].m_dwAddr,addr @byteOld,size @byteOld,addr @nNumOfBytesWritten
		inc  edi
		add esi,sizeof tagStepOverBp
	.endw  
	
	ret
RestorAllCCBps endp
	
SetAllCCBps proc uses esi edi
LOCAL @byteOld:BYTE
LOCAL @nNumOfBytesWritten:DWORD
	
	;0xcc断点有两种 一般断点表  和 临时/单步断点表
	;还原一般断点表
	assume esi:ptr tagNormalBp
	mov esi,offset g_arrayNormalBps
	xor edi,edi
	.while edi < g_nNumOfCurNormalBp
		;写入CC
		invoke WriteProcessMemory,g_hProc,[esi].m_dwAddr,offset g_byteCC,size g_byteCC,addr @nNumOfBytesWritten
		inc  edi
		add esi,sizeof tagNormalBp
	.endw  
	
	;还原单步断点表
	assume esi:ptr tagStepOverBp
	mov esi,offset g_arrayStepOverBps
	xor edi,edi
	.while edi < g_nNumOfCurStepOverBp
		;写入CC
		invoke WriteProcessMemory,g_hProc,[esi].m_dwAddr,offset g_byteCC,size g_byteCC,addr @nNumOfBytesWritten
		inc  edi
		add esi,sizeof tagStepOverBp
	.endw  
	
	ret
	
SetAllCCBps endp
	
	
	;这是有节表的Dump
DumpCurProcess proc uses ebx esi edi
LOCAL @hFile:HANDLE
LOCAL @hMap:HANDLE
LOCAL @pAddr:LPVOID
LOCAL @DosHdr:IMAGE_DOS_HEADER
LOCAL @NTHdr:IMAGE_NT_HEADERS
LOCAL  @dwNumOfBytesWritten:DWORD
LOCAL @dwSizeOfImage:DWORD
LOCAL @dwFileSize:DWORD
LOCAL @dwNumOfSections:DWORD
LOCAL @pSectionTable:ptr IMAGE_SECTION_HEADER
	
	;先还原所有CC断点
	invoke RestorAllCCBps
	
	
	
	;创建文件
	invoke CreateFile,offset g_szDumpFile,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.IF eax == 0
		ret
	.endif
	mov @hFile, eax
	
	;读dos头 
	invoke ReadProcessMemory,g_hProc,g_dwImageBase,addr @DosHdr,sizeof @DosHdr,addr @dwNumOfBytesWritten
	
	;读NT头,拿到SizeofImage
	mov ebx,@DosHdr.e_lfanew
	add ebx,g_dwImageBase
	invoke ReadProcessMemory,g_hProc,ebx,addr @NTHdr,sizeof @NTHdr,addr @dwNumOfBytesWritten
	mov eax,@NTHdr.OptionalHeader.SizeOfImage
	mov @dwSizeOfImage,eax
	
	;设置文件大小为SizeofImage，之后再截断
	invoke SetFilePointer,@hFile,@dwSizeOfImage,NULL,FILE_BEGIN
	invoke SetEndOfFile,@hFile
	invoke SetFilePointer,@hFile,NULL,NULL,FILE_BEGIN   ;还原文件指针
	;做文件映射
	invoke CreateFileMapping, @hFile, NULL, PAGE_READWRITE, 0, 0, NULL
	.IF eax == 0
		ret
	.endif
	mov @hMap, eax
	
	invoke MapViewOfFile, @hMap, FILE_MAP_ALL_ACCESS, 0, 0, 0
	.IF eax == 0
		ret
	.endif
	mov @pAddr, eax
	
	;复制Headers
	;先拿sizeofheaders
	invoke ReadProcessMemory,g_hProc,g_dwImageBase,@pAddr,@NTHdr.OptionalHeader.SizeOfHeaders,addr @dwNumOfBytesWritten
	push @NTHdr.OptionalHeader.SizeOfHeaders
	pop @dwFileSize ;增加文件大小
	
	;根据节表复制各个节(前面复制了headers，可以在文件映射做事了)
	;先拿节表
	mov ebx,@DosHdr.e_lfanew
	add ebx,@pAddr
	add ebx,IMAGE_NT_HEADERS.OptionalHeader     ;得到可选项头的地址
	movzx eax,@NTHdr.FileHeader.SizeOfOptionalHeader 
	add ebx, eax     ;加上可选项头的大小得到节表地址
	mov @pSectionTable,ebx
	
	xor ecx,ecx
	mov ebx,@pSectionTable
	assume ebx:ptr IMAGE_SECTION_HEADER
	
	movzx eax,@NTHdr.FileHeader.NumberOfSections
	mov @dwNumOfSections,eax
	.WHILE ecx < @dwNumOfSections
		push ecx        ;防止ECX被修改
		
		mov esi,[ebx].VirtualAddress        ;RVA
		add esi,g_dwImageBase
		
		mov edi,[ebx].PointerToRawData ;FA
		add edi,@pAddr
		
		mov ecx,[ebx].SizeOfRawData     ;size of section in files
		
		add @dwFileSize,ecx ;增加文件大小
		
		invoke ReadProcessMemory,g_hProc,esi,edi,ecx,addr @dwNumOfBytesWritten
		
		pop ecx
		inc ecx
		add ebx,size  IMAGE_SECTION_HEADER
	.ENDW
	
	
	;重设所有断点
	invoke SetAllCCBps
	
	;读取完毕，截断
	;关闭文件映射
	invoke UnmapViewOfFile,@pAddr
	invoke CloseHandle,@hMap
	;截断
	invoke SetFilePointer,@hFile,@dwFileSize,NULL,FILE_BEGIN
	invoke SetEndOfFile,@hFile
	invoke SetFilePointer,@hFile,NULL,NULL,FILE_BEGIN   ;还原文件指针
	invoke CloseHandle,@hFile
	ret
	
DumpCurProcess endp
	
SetBM proc uses ecx esi edi dwType:DWORD,dwAddr:DWORD,dwLen:DWORD
LOCAL @mbi:MEMORY_BASIC_INFORMATION
LOCAL @nCurBpID:DWORD
	invoke RtlZeroMemory,addr @mbi,sizeof @mbi
	;检查重叠
	mov ecx,0
	mov esi,offset g_tableBMBps
	.WHILE ecx < g_nNumOfCurBMBps
		assume esi:ptr tagMemBp
		invoke IsTwoAddrOverlapped,dwAddr,dwLen,[esi].m_dwAddr,[esi].m_dwLen
		.IF eax		;重叠则设置失败
			invoke crt_printf,offset g_szBMOverlappedFmt,[esi].m_dwID
			mov eax,FALSE
			ret
		.ENDIF
		inc ecx
		add esi,sizeof tagMemBp
	.ENDW
	assume esi:nothing
	
	;遍历每个分页，判断是否缺页
	;计算出开始的分页和结束的分页
	mov esi,dwAddr
	mov edi,esi
	add edi,dwLen
	dec edi
	and esi,0FFFFF000h
	and edi,0FFFFF000h
	
	.WHILE esi<=edi
		invoke RtlZeroMemory,addr @mbi,sizeof @mbi
		invoke VirtualQueryEx,g_hProc,esi,addr @mbi,sizeof @mbi
		.IF @mbi.State == MEM_FREE || @mbi.State == MEM_RESERVE 
			invoke crt_printf,offset g_szBMPageFault
			mov eax,FALSE
			ret
		.endif
		add esi,01000h
	.ENDW
	
	;在断点表中加入断点
	invoke AddBMBpTable,dwAddr,dwLen,dwType ;返回的是ID
	mov @nCurBpID,eax
	
	;再次遍历每个分页
	;1.和ID加入到ID-分页表
	;2.每个分页和原有属性存到分页表（检查是否存在，存在则个数加一，不存在则添加新的)修改分页的内存属性为不可访问
	;计算出开始的分页和结束的分页
	mov esi,dwAddr
	mov edi,esi
	add edi,dwLen
	dec edi
	and esi,0FFFFF000h
	and edi,0FFFFF000h
	
	.WHILE esi<=edi
		invoke AddBMIDPageTable,@nCurBpID,esi
		invoke AddBMPageTable,esi
		add esi,01000h
	.ENDW
	
	ret
	
SetBM endp
	
	
ClearMemBp proc uses esi ecx dwID:DWORD
	
	;遍历ID-分页表,找到对应ID的所有分页
	.WHILE TRUE
		invoke FindIDPageTableAddrByID,dwID     ;每次查找第一个ID为dwID的，直到找不到为止
		.IF eax == 0
			.BREAK
		.endif
		mov esi,eax
		assume esi:ptr tagBMIDPage
		invoke DelBMPageTableByPageAddr,[esi].m_dwPageAddr  ;在分页表中删掉对应分页，个数-1，为0则恢复内存属性，并且彻底删除
		invoke DeIIDPageTableAddrByAddr,esi ;删掉这个ID-分页表项
	.endw
	
	
	;最后删除断点表中的断点
	invoke DelBMBpTableByID,dwID
	
	
	ret
	
ClearMemBp endp
	
FindBMBpTableByID proc uses esi ecx dwID:DWORD
	;返回结构体地址
	assume esi:ptr tagMemBp
	mov esi,offset g_tableBMBps
	xor ecx,ecx
	.WHILE ecx < g_nNumOfCurBMBps
		mov eax,dwID
		.IF eax == [esi].m_dwID
			mov eax,esi
			ret
		.endif
		inc ecx
		add esi,sizeof tagMemBp
	.endw
	
	mov eax,0
	ret ;返回断点结构首地址，未找到返回0
	
FindBMBpTableByID endp
	
DelBMBpTableByID proc uses esi edi dwID:DWORD
LOCAL @dwBytesToMove:DWORD       
	invoke FindBMBpTableByID,dwID
	mov esi,eax
	assume esi:ptr tagMemBp
	mov edi,esi
	add esi,sizeof tagMemBp
	mov eax,offset g_tableBMBpsLenth
	sub eax,esi
	mov @dwBytesToMove,eax
	invoke RtlMoveMemory,edi,esi,@dwBytesToMove
	
	dec g_nNumOfCurBMBps
	
	
	ret
	
DelBMBpTableByID endp
	
DeIIDPageTableAddrByAddr proc uses esi edi dwAddr:DWORD
LOCAL @dwBytesToMove:DWORD    
	mov esi,dwAddr
	mov edi,esi
	add esi,sizeof tagBMIDPage
	mov eax,offset g_tableBMIDPageLenth
	sub eax,esi
	mov @dwBytesToMove,eax
	invoke RtlMoveMemory,edi,esi,@dwBytesToMove
	
	dec g_nNumOfCurBMIDPage
	ret
	
DeIIDPageTableAddrByAddr endp
	
DelBMPageTableByPageAddr proc uses esi edi dwPageAddr:DWORD
LOCAL @dwOldProt:DWORD
LOCAL @dwBytesToMove:DWORD
	;在分页表中删掉对应分页，个数-1，为0则恢复内存属性，并且彻底删除
	;找到
	invoke FindBMPageTableByPageAddr,dwPageAddr
	mov esi,eax
	assume esi:ptr tagBMPage
	dec [esi].m_dwNumOfBp
	.IF [esi].m_dwNumOfBp == 0
		;恢复内存属性，彻底删除
		invoke VirtualProtectEx, g_hProc, dwPageAddr, 1000h, [esi].m_dwOldProc, addr @dwOldProt
		;彻底删除
		mov edi,esi
		add esi,sizeof tagBMPage
		mov eax,offset g_tableBMPageLenth
		sub eax,esi
		mov @dwBytesToMove,eax
		invoke RtlMoveMemory,edi,esi,@dwBytesToMove
		;个数-1
		dec g_nNumOfCurBMPage
	.endif
	
	ret
	
DelBMPageTableByPageAddr endp
	
ListAllMemBp proc uses esi edi 
LOCAL @pszType:DWORD
	
	.IF g_nNumOfCurBMBps==0
		invoke crt_printf, offset g_szThereIsNoBMBpTip        ;没有断点
		ret
	.endif
	
	invoke crt_printf, offset g_szBMTableHead        ;表头
	
	assume esi:ptr tagMemBp
	mov esi,offset g_tableBMBps
	xor edi,edi
	.while edi < g_nNumOfCurBMBps
		
		.IF [esi].m_dwType == BMT_WRITE
			mov @pszType,offset g_szBMWrite
		.ELSEIF [esi].m_dwType == BMT_ACCESS
			mov @pszType,offset g_szBMAccess
		.ENDIF
		
		
		invoke crt_printf, offset g_szPrintBMFmt, [esi].m_dwID,[esi].m_dwAddr,[esi].m_dwLen, @pszType 
		inc  edi
		add esi,sizeof tagMemBp
	.endw
	
	ret
	
ListAllMemBp endp
	
ListBMIDPageTable proc uses esi edi
	.IF g_nNumOfCurBMIDPage==0
		invoke crt_printf, offset g_szThereIsNoBMBpTip        ;没有断点
		ret
	.endif
	
	invoke crt_printf, offset g_szBMIDPageTableHead        ;表头
	
	assume esi:ptr tagBMIDPage
	mov esi,offset g_tableBMIDPage
	xor edi,edi
	.while edi < g_nNumOfCurBMIDPage
		invoke crt_printf, offset g_szPrintBMIDPageFmt, [esi].m_dwID,[esi].m_dwPageAddr
		inc  edi
		add esi,sizeof tagBMIDPage
	.endw
	
	ret
	
ListBMIDPageTable endp
	
FindIDPageTableAddrByID proc uses ecx esi dwID:DWORD
	
	;找到第一个ID为dwID的，返回结构体地址
	assume esi:ptr tagBMIDPage
	mov esi,offset g_tableBMIDPage
	xor ecx,ecx
	.WHILE ecx < g_nNumOfCurBMIDPage
		mov eax,dwID
		.IF eax == [esi].m_dwID
			mov eax,esi
			ret
		.endif
		inc ecx
		add esi,sizeof tagBMIDPage
	.endw
	
	mov eax,0
	ret ;返回断点结构首地址，未找到返回0
FindIDPageTableAddrByID endp
	
FindAddrInWhichBMBp proc uses ecx esi edx dwAddr :DWORD
	
	assume esi:ptr tagMemBp
	mov esi,offset g_tableBMBps
	xor ecx,ecx
	.WHILE ecx < g_nNumOfCurBMBps
		mov eax,dwAddr
		mov edx,[esi].m_dwAddr
		add edx,[esi].m_dwLen
		.IF eax >= [esi].m_dwAddr && eax < edx
			mov eax,esi
			ret
		.endif
		inc ecx
		add esi,sizeof tagMemBp
	.endw
	
	mov eax,0
	ret ;返回断点结构首地址，未找到返回0
	
FindAddrInWhichBMBp endp
	
FindBMPageTableByPageAddr proc uses ecx esi  dwPageAddr:DWORD
	assume esi:ptr tagBMPage
	mov esi,offset g_tableBMPage
	xor ecx,ecx
	.while ecx < g_nNumOfCurBMPage
		mov eax,[esi].m_dwPageAddr
		.IF eax == dwPageAddr
			mov eax,esi
			ret
		.endif
		inc ecx
		add esi,sizeof tagBMPage 
	.endw
	mov eax,0
	ret
FindBMPageTableByPageAddr endp
	
AddBMPageTable proc uses esi dwPageAddr:DWORD
LOCAL @mbi:MEMORY_BASIC_INFORMATION   
LOCAL @dwOldProt:DWORD
	
	;检查分页是否存在
	invoke FindBMPageTableByPageAddr,dwPageAddr
	.IF eax !=0
		;存在，则个数加一
		mov esi,eax
		assume esi:ptr tagBMPage
		inc [esi].m_dwNumOfBp
	.ELSE
		;不存在
		;内存的属性修改为不可访问,存下原来属性
		invoke VirtualProtectEx, g_hProc, dwPageAddr, 1000h, PAGE_NOACCESS, addr @dwOldProt
		
		;计算存入的偏移
		mov eax,sizeof tagBMPage
		mul g_nNumOfCurBMPage
		add eax,offset g_tableBMPage 
		mov esi,eax
		;存三个成员
		push dwPageAddr
		pop [esi].m_dwPageAddr
		push @dwOldProt
		pop [esi].m_dwOldProc
		mov [esi].m_dwNumOfBp,1
		
		inc g_nNumOfCurBMPage
	.ENDIF
	
	ret
	
AddBMPageTable endp
	
AddBMIDPageTable proc uses edi dwID:DWORD,dwPageAddr:DWORD
	mov eax,sizeof tagBMIDPage
	mul g_nNumOfCurBMIDPage
	add eax,offset g_tableBMIDPage ;计算存入的偏移
	
	mov edi,eax
	assume edi:ptr tagBMIDPage
	push dwID
	pop [edi].m_dwID
	push dwPageAddr
	pop [edi].m_dwPageAddr
	
	inc g_nNumOfCurBMIDPage
	
	mov eax,edi ;返回地址
	
	ret
	
AddBMIDPageTable endp
	
AddBMBpTable proc uses edi dwAddr:DWORD,dwLen:DWORD,dwType:DWORD
	mov eax,sizeof tagMemBp
	mul g_nNumOfCurBMBps
	add eax,offset g_tableBMBps ;计算存入的偏移
	
	;存入四个值
	mov edi,eax
	assume edi:ptr tagMemBp
	push dwAddr
	pop [edi].m_dwAddr
	push dwLen
	pop [edi].m_dwLen
	push dwType
	pop [edi].m_dwType
	
	mov eax,g_nCurAvailableID
	mov [edi].m_dwID,eax
	
	inc g_nCurAvailableID   ;增加下次可用ID
	inc g_nNumOfCurBMBps    ;增加内存断点个数
	
	mov eax,[edi].m_dwID
	
	assume edi:ptr nothing
	ret
	
AddBMBpTable endp
	
IsTwoAddrOverlapped proc uses ebx dwAddr1:DWORD,dwLen1:DWORD,dwAddr2:DWORD,dwLen2:DWORD
	;2首部是否在1内部 dwaddr1 <= dwaddr2 < dwaddr1 + dwlen1
	mov eax,dwAddr2
	mov ebx,dwAddr1
	add ebx,dwLen1
	.IF eax >= dwAddr1 && eax < ebx
		mov eax,TRUE
		ret
	.ENDIF
	;1首部是否在2内部 dwaddr2 <= dwaddr1 < dwaddr2 + dwlen2
	mov eax,dwAddr1
	mov ebx,dwAddr2
	add ebx,dwLen2
	.IF eax >= dwAddr2 && eax < ebx
		mov eax,TRUE
		ret
	.ENDIF
	
	mov eax,FALSE
	ret
IsTwoAddrOverlapped endp
	
ClearHardwareBp  proc uses esi nID:DWORD
LOCAL @ctx:CONTEXT       
	invoke GetContext,addr @ctx
	;将对应的DR寄存器标志禁用
	.IF nID == 0
		and @ctx.iDr7,0FFFFFFFEh
	.ELSEIF nID == 1
		and @ctx.iDr7,0FFFFFFFBh
	.ELSEIF nID == 2
		and @ctx.iDr7,0FFFFFFEFh
	.ELSEIF nID == 3
		and @ctx.iDr7,0FFFFFFBFh
	.endif
	;表标志禁用
	mov eax,sizeof tagHardwareBp
	mul  nID
	add eax,offset g_arrayHardwareBps
	mov esi,eax
	assume esi:ptr tagHardwareBp
	mov [esi].m_dwIsUsed,FALSE
	
	;数量-1
	dec g_nNumOfCurHardwareBp
	
	invoke SetContext,addr @ctx
	
	ret
ClearHardwareBp endp
	
	;设置硬件断点
SetBH proc uses esi edx dwType:DWORD,dwAddr:DWORD,dwLen:DWORD
LOCAL @ctx:CONTEXT
LOCAL @hThread:HANDLE
LOCAL @nFreeIdx:DWORD
LOCAL @nLenRW:DWORD     ;拼接的LenRW
	invoke GetContext,addr @ctx
	;检查是否有空闲寄存器
	.IF g_nNumOfCurHardwareBp == 4      ;已满
		invoke crt_printf, offset g_szHardWareBpFullTip 
		ret
	.endif
	
	;找到空闲位置，存入表中，设置对应的寄存器
	mov esi,offset g_arrayHardwareBps
	assume esi:ptr tagHardwareBp
	
	mov @nFreeIdx,0
	.WHILE @nFreeIdx < 4
		.IF [esi].m_dwIsUsed == FALSE
			.BREAK
		.endif
		add esi,sizeof tagHardwareBp
		inc @nFreeIdx
	.endw
	
	;存入表中
	mov [esi].m_dwIsUsed,TRUE
	push dwAddr
	pop [esi].m_dwAddr
	push dwLen
	pop [esi].m_dwLen
	push dwType
	pop [esi].m_dwType
	
	; 拼出LenRW
	mov eax,dwLen
	mov @nLenRW,eax
	shl    @nLenRW,2
	mov eax,@nLenRW
	add eax,dwType
	mov @nLenRW,eax
	
	;设置寄存器
	;存地址,启用寄存器L位置,设置R/W和LEN位置
	.IF @nFreeIdx == 0
		mov eax,dwAddr
		mov @ctx.iDr0,eax   ;设置地址
		or     @ctx.iDr7,00000001b      ;设置L位置
		mov edx,@nLenRW
		mov eax,@ctx.iDr7                   ;设置lenRW
		and eax,0FFF0FFFFh                 ;清掉原有的
		shl  edx,16
		add eax,edx
		mov @ctx.iDr7,eax
	.ELSEIF    @nFreeIdx == 1
		mov eax,dwAddr
		mov @ctx.iDr1,eax
		or     @ctx.iDr7,00000100b
		mov edx,@nLenRW
		mov eax,@ctx.iDr7
		and eax,0FF0FFFFFh                 ;清掉原有的
		shl  edx,20
		add eax,edx
		mov @ctx.iDr7,eax
	.ELSEIF    @nFreeIdx == 2
		mov eax,dwAddr
		mov @ctx.iDr2,eax
		or     @ctx.iDr7,00010000b
		mov edx,@nLenRW
		mov eax,@ctx.iDr7
		and eax,0F0FFFFFFh                 ;清掉原有的
		shl  edx,24
		add eax,edx
		mov @ctx.iDr7,eax
	.ELSEIF    @nFreeIdx == 3
		mov eax,dwAddr
		mov @ctx.iDr3,eax
		or     @ctx.iDr7,01000000b
		mov edx,@nLenRW
		mov eax,@ctx.iDr7
		and eax,0FFFFFFFh                 ;清掉原有的
		shl  edx,28
		add eax,edx
		mov @ctx.iDr7,eax
	.endif
	
	inc g_nNumOfCurHardwareBp
	invoke SetContext,addr @ctx
	
	ret
	
SetBH endp
	
ListAllHardwareBps proc uses esi edi
LOCAL @pszLen:DWORD
LOCAL @pszType:DWORD
	.IF g_nNumOfCurHardwareBp==0
		invoke crt_printf, offset g_szThereIsNoBpTip        ;没有断点
		ret
	.endif
	
	invoke crt_printf, offset g_szBHTableHead        ;表头
	
	assume esi:ptr tagHardwareBp
	mov esi,offset g_arrayHardwareBps
	xor edi,edi
	.while edi < 4
		.IF ![esi].m_dwIsUsed
			invoke crt_printf, offset g_szNotUsedFmt,edi
			inc  edi
			add esi,sizeof tagHardwareBp
			.CONTINUE
		.endif
		
		.IF [esi].m_dwLen == BHL_BYTE
			mov @pszLen,offset g_szByte
		.ELSEIF [esi].m_dwLen == BHL_WORD
			mov @pszLen,offset g_szWord
		.ELSEIF [esi].m_dwLen == BHL_DWORD
			mov @pszLen,offset g_szDWord
		.ENDIF
		
		.IF [esi].m_dwType == BHT_EXECUTE
			mov @pszType,offset g_szExecute
		.ELSEIF [esi].m_dwType == BHT_ACCESS
			mov @pszType,offset g_szAccess
		.ELSEIF [esi].m_dwType == BHT_WRITE
			mov @pszType,offset g_szWrite
		.ENDIF
		
		
		invoke crt_printf, offset g_szPrintBHFmt, edi,[esi].m_dwAddr,@pszLen, @pszType      ;TODO :目前都是一般断点
		inc  edi
		add esi,sizeof tagHardwareBp
	.endw
	
	ret
	
ListAllHardwareBps endp
	
GetContext proc uses esi pCtx:ptr CONTEXT 
LOCAL @hThread:HANDLE
	
	invoke RtlZeroMemory, pCtx, size CONTEXT
	
	mov esi, pCtx
	assume esi:ptr CONTEXT
	
	
	invoke OpenThread,THREAD_ALL_ACCESS,FALSE, g_de.dwThreadId
	mov @hThread, eax
	
	mov [esi].ContextFlags, CONTEXT_FULL or CONTEXT_DEBUG_REGISTERS
	invoke GetThreadContext, @hThread, pCtx
	
	assume esi:nothing
	
	invoke CloseHandle, @hThread
	ret
	
GetContext endp
	
SetContext proc pCtx:ptr CONTEXT 
LOCAL @hThread:HANDLE
	
	invoke OpenThread,THREAD_ALL_ACCESS,FALSE, g_de.dwThreadId
	mov @hThread, eax
	
	invoke SetThreadContext, @hThread, pCtx
	
	invoke CloseHandle, @hThread
	
	ret
	
SetContext endp
	
	
ClearNormalBp proc uses esi edi dwIdx:DWORD
LOCAL @byteOld:BYTE
LOCAL @nNumOfBytesWritten:DWORD
LOCAL @nBytesToMove:DWORD
	;1.把断点原字节写回
	;算地址
	mov eax,sizeof tagNormalBp
	mul dwIdx
	add eax,offset g_arrayNormalBps
	mov esi,eax
	
	assume esi:ptr tagNormalBp
	mov al,[esi].m_byteOld
	mov @byteOld,al
	invoke WriteProcessMemory,g_hProc,[esi].m_dwAddr,addr @byteOld,size @byteOld,addr @nNumOfBytesWritten
	assume esi:nothing
	
	;2.将断点删除
	mov edi,esi
	add esi,sizeof tagNormalBp
	mov eax,offset g_arrayNormalBpsLength
	sub eax,esi
	mov @nBytesToMove,eax
	invoke RtlMoveMemory,edi,esi,@nBytesToMove
	
	dec g_nNumOfCurNormalBp
	
	
	ret
	
ClearNormalBp endp
	
	
	
	
ListAllBps proc uses edi esi ebx
	.IF g_nNumOfCurNormalBp==0
		invoke crt_printf, offset g_szThereIsNoBpTip        ;没有断点
		ret
	.endif
	
	invoke crt_printf, offset g_szTableHead        ;表头
	
	assume esi:ptr tagNormalBp
	mov esi,offset g_arrayNormalBps
	xor edi,edi
	.while edi < g_nNumOfCurNormalBp
		movzx ebx,[esi].m_byteOld
		invoke crt_printf, offset g_szPrintBpFmt, edi,[esi].m_dwAddr,ebx, offset g_szTypeNormal      ;TODO :目前都是一般断点
		inc  edi
		add esi,sizeof tagNormalBp
	.endw
	
	ret
	
ListAllBps endp
	
GetHardWareBpAddrInTable  proc uses esi ecx dwAddr:DWORD
	
	assume esi:ptr tagHardwareBp
	mov esi,offset g_arrayHardwareBps
	xor ecx,ecx
	.WHILE ecx < 4
		.IF ![esi].m_dwIsUsed
			inc ecx
			add esi,sizeof tagHardwareBp
			.continue
		.endif
		mov eax,[esi].m_dwAddr
		.IF  eax==dwAddr
			mov eax,esi
			ret
		.ENDIF
		inc ecx
		add esi,sizeof tagHardwareBp
	.ENDW
	
	assume esi:nothing
	
	mov eax,0          ;未找到
	ret
GetHardWareBpAddrInTable endp
	
GetNormalBpAddrInTable  proc uses esi ecx dwAddr:DWORD
	
	assume esi:ptr tagNormalBp
	mov esi,offset g_arrayNormalBps
	xor ecx,ecx
	.WHILE ecx < g_nNumOfCurNormalBp
		mov eax,[esi].m_dwAddr
		.IF  eax==dwAddr
			mov eax,esi
			ret
		.ENDIF
		inc ecx
		add esi,sizeof tagNormalBp
	.ENDW
	
	assume esi:nothing
	
	mov eax,0          ;未找到
	ret
GetNormalBpAddrInTable endp
	
SaveNormalBpToTable proc uses ebx byteOld:DWORD,dwBpAddr:DWORD
	;查看断点是否已经存在
	invoke GetNormalBpAddrInTable,dwBpAddr
	.IF eax!=0
		ret
	.endif
	
	mov ebx, offset g_arrayNormalBps ;计算应该存放的地址
	mov eax,sizeof tagNormalBp
	mul  g_nNumOfCurNormalBp
	add eax,ebx
	
	assume eax:ptr tagNormalBp
	push dwBpAddr
	pop [eax].m_dwAddr                       ;1.存断点地址
	mov [eax].m_bIsEnabled,1               ;2.启用断点
	mov ebx,byteOld
	mov [eax].m_byteOld,bl
	assume eax:nothing                               
	
	;增加断点个数
	inc g_nNumOfCurNormalBp
	
	ret
SaveNormalBpToTable endp
	
	
	
GetStepOverBpAddrInTable  proc uses esi ecx dwAddr:DWORD
	
	assume esi:ptr tagStepOverBp
	mov esi,offset g_arrayStepOverBps
	xor ecx,ecx
	.WHILE ecx < g_nNumOfCurStepOverBp
		mov eax,[esi].m_dwAddr
		.IF  eax==dwAddr
			mov eax,esi
			ret
		.ENDIF
		inc ecx
		add esi,sizeof tagStepOverBp
	.ENDW
	
	assume esi:nothing
	
	mov eax,0          ;未找到
	ret
GetStepOverBpAddrInTable endp
	
SaveStepOverBpToTable proc uses ebx byteOld:DWORD,dwBpAddr:DWORD
	
	;查看断点是否已经存在
	invoke GetStepOverBpAddrInTable,dwBpAddr
	.IF eax!=0
		ret
	.endif
	
	mov ebx, offset g_arrayStepOverBps ;计算应该存放的地址
	mov eax,sizeof tagStepOverBp
	mul  g_nNumOfCurStepOverBp
	add eax,ebx
	
	assume eax:ptr tagStepOverBp
	push dwBpAddr
	pop [eax].m_dwAddr                       ;1.存断点地址
	mov ebx,byteOld
	mov [eax].m_byteOld,bl
	assume eax:nothing                               
	
	;增加断点个数
	inc g_nNumOfCurStepOverBp
	
	ret
SaveStepOverBpToTable endp	
	
	
	;仅在地址处设置0xCC，返回原字节
SetBp proc dwAddr:DWORD
LOCAL @nNumOfBytesReaded:DWORD
LOCAL @nNumOfBytesWritten:DWORD
LOCAL @byteOld:BYTE
LOCAL @pSaveAddr:DWORD
	
	;保存原有指令的首字节
	invoke ReadProcessMemory,g_hProc,dwAddr,addr @byteOld,sizeof @byteOld,addr @nNumOfBytesReaded
	
	;写入CC
	invoke WriteProcessMemory,g_hProc,dwAddr,offset g_byteCC,size g_byteCC,addr @nNumOfBytesWritten
	
	;返回原来指令的首字节
	movzx  eax,@byteOld
	
	ret
	
SetBp endp
	
RestoreBp proc uses esi edi  dwAddr:DWORD
LOCAL @nNumOfBytesWritten:DWORD
LOCAL @ctx:CONTEXT
LOCAL @hThread:HANDLE
LOCAL @byteOld:BYTE
LOCAL @bIsStepOverBp:DWORD
LOCAL @nBytesToMove:DWORD
	
	mov @bIsStepOverBp,FALSE
	
	;首先判断是否是p命令断点
	invoke GetStepOverBpAddrInTable,dwAddr
	mov esi,eax
	.IF eax !=0
		;找到了
		mov @bIsStepOverBp,TRUE
		
		;写入原指令字节
		assume eax:ptr tagStepOverBp
		mov al,[eax].m_byteOld
		mov @byteOld,al
		assume eax:nothing
		invoke WriteProcessMemory,g_hProc,dwAddr,addr @byteOld,size @byteOld,addr @nNumOfBytesWritten
		
		;回退EIP，删除断点
		invoke DecEip
		
		;2.将断点删除
		mov edi,esi
		add esi,sizeof tagStepOverBp
		mov eax,offset g_arrayStepOverBpsLength
		sub eax,esi
		mov @nBytesToMove,eax
		invoke RtlMoveMemory,edi,esi,@nBytesToMove
		
		dec g_nNumOfCurStepOverBp
		
		;如果是Go Ret,判断是否抵达Ret
		.IF g_bIsGoRet
		    invoke JudgeIsRetReached
		    .IF eax
		        mov g_bIsGoRet,FALSE
		    .ELSE 
		        invoke SetTraceOver
		    .endif
		.endif
		    
		
		
	.endif
	
	;写入原指令字节
	;断点表中找到原断点
	invoke GetNormalBpAddrInTable,dwAddr
	.if eax == 0    ;没找到
		.IF @bIsStepOverBp == TRUE
		        .IF g_bIsGoRet
		            ret
		        .ELSE
		            invoke InputCommand
		        .endif
			ret     ;只是p命令的断点，直接返回，无需再设置TF
		.ELSE
			invoke crt_printf, offset g_szErrorBpNotFoundInTable        ;未找到
			invoke InputCommand
			ret     
		.endif
	.endif
	
	;找到了，说明是一般断点
	assume eax:ptr tagNormalBp
	mov al,[eax].m_byteOld
	mov @byteOld,al
	assume eax:nothing
	invoke WriteProcessMemory,g_hProc,dwAddr,addr @byteOld,size @byteOld,addr @nNumOfBytesWritten
	
	
	
	;回退eip,设置TF
	.IF @bIsStepOverBp == FALSE
		invoke DecEip   ;如果已经回退过不用回退
	.ENDIF
	invoke SetTF
	
	;设置最后一次命中的断点
	push dwAddr
	pop g_dwLastBpAddr
	mov g_bIsNormallBpSingleStep,TRUE
	invoke crt_printf, offset g_szBpTip,dwAddr      ;输出命中一般断点
	
	invoke InputCommand
	ret
	
RestoreBp endp
	
DecEip proc 
LOCAL @ctx:CONTEXT
LOCAL @hThread:HANDLE
	
	invoke RtlZeroMemory, addr @ctx, size @ctx
	
	;回退EIP
	invoke OpenThread,THREAD_ALL_ACCESS,FALSE, g_de.dwThreadId
	mov @hThread, eax
	
	mov @ctx.ContextFlags, CONTEXT_CONTROL
	invoke GetThreadContext, @hThread, addr @ctx
	dec @ctx.regEip
	invoke SetThreadContext, @hThread, addr @ctx
	
	invoke CloseHandle, @hThread
	ret
	
DecEip endp
	
SetTF proc
LOCAL @hThread:HANDLE
LOCAL @ctx:CONTEXT
	
	invoke RtlZeroMemory,addr @ctx,sizeof @ctx
	;设置TF
	;没有给context但是有线程ID，可以用
	invoke OpenThread,THREAD_ALL_ACCESS,FALSE,g_de.dwThreadId
	mov @hThread,eax
	mov @ctx.ContextFlags,CONTEXT_CONTROL
	invoke GetThreadContext,@hThread,addr @ctx
	
	or @ctx.regFlag,100h  ;TF bit
	
	invoke SetThreadContext,@hThread,addr @ctx
	
	invoke CloseHandle, @hThread
	ret
	
SetTF endp
	
GetEip proc
LOCAL @ctx:CONTEXT
LOCAL @hThread:HANDLE
	
	invoke RtlZeroMemory, addr @ctx, size @ctx
	
	;回退EIP，设TF
	invoke OpenThread,THREAD_ALL_ACCESS,FALSE, g_de.dwThreadId
	mov @hThread, eax
	
	mov @ctx.ContextFlags, CONTEXT_CONTROL
	invoke GetThreadContext, @hThread, addr @ctx
	
	invoke CloseHandle, @hThread
	
	mov eax, @ctx.regEip
	ret
	
GetEip endp
	
DisasmLineEx proc uses esi edi ebx pCode:LPBYTE , nCodeSize:DWORD , dwAddr:DWORD , pszAsm:LPSTR
LOCAL @dwAddrInMachineCode:DWORD
LOCAL @szStartAddr:PSTR
LOCAL @dwCodeLen:DWORD
LOCAL @chRightMost:BYTE
LOCAL @szAPIName[MAX_PATH]:BYTE
LOCAL @dwAPIAddr:DWORD
LOCAL @dwBytesReadWrite:DWORD
	
	;此时反汇编处如果有CC断点，要看看先能不能复原,列出会换成CC断点的可能
	mov eax,pCode
	mov al,[eax]
	.IF al == 0CCh
		invoke GetNormalBpAddrInTable,dwAddr
		.IF eax != 0
			mov esi,eax
			assume esi:ptr tagNormalBp
			mov al,[esi].m_byteOld
			mov ebx,pCode
			mov byte ptr [ebx],al
		.ELSE
			invoke GetStepOverBpAddrInTable,dwAddr
			.IF eax != 0
				mov esi,eax
				assume esi:ptr tagStepOverBp
				mov al,[esi].m_byteOld
				mov ebx,pCode
				mov byte ptr [ebx],al
			.endif
		.endif
	.endif
	invoke DisasmLine, pCode, nCodeSize, dwAddr, pszAsm
	mov @dwCodeLen,eax
	
	;call dword ptr [xxxxx] / jxx dword ptr [xxxxx]
	;call 0x111
	;拿到地址先
	fn crt_strstr,pszAsm,"call"
	mov esi,eax
	
	fn crt_strstr,pszAsm,"j"
	mov edi,eax
	
	.IF !(esi||edi)
	    jmp LB_DisasmLineEx_END
	.endif
	
	
	fn crt_strstr,pszAsm,"["    ;locate [xxxx]
	.IF eax ==0
	     jmp LB_DisasmLineEx_END
	.endif
	mov @szStartAddr,eax
	inc @szStartAddr        ;locate xxxx]
	
	fn crt_sscanf,@szStartAddr,"%x%c",addr @dwAddrInMachineCode,addr @chRightMost
	.IF eax !=2 || @chRightMost!=']'
	    jmp LB_DisasmLineEx_END
	.endif
	
	invoke ReadProcessMemory,g_hProc,@dwAddrInMachineCode,addr @dwAPIAddr,sizeof @dwAPIAddr,addr @dwBytesReadWrite
	
	invoke RtlZeroMemory,addr @szAPIName,sizeof @szAPIName
	invoke GetAPINameByAddr,@dwAPIAddr,addr @szAPIName
	
	fn crt_sprintf, @szStartAddr,"%s]",addr @szAPIName
	
	
LB_DisasmLineEx_END:	
	mov eax,@dwCodeLen
	ret
	
DisasmLineEx endp
	
	
Disasm8Lines proc dwStartAddr:DWORD
LOCAL @bufCode[16]:BYTE    
LOCAL @szBufAsm[64]:BYTE
LOCAL @dwCodeLen:DWORD
LOCAL @dwBytesReadWrite:DWORD
LOCAL @dwCurAddr:DWORD
LOCAL @nIdx:DWORD
	
	mov @nIdx,0
	mov eax,dwStartAddr
	mov @dwCurAddr,eax
	
	.WHILE @nIdx<8
		invoke ReadProcessMemory, g_hProc, @dwCurAddr, addr @bufCode, 16, addr @dwBytesReadWrite
		;此时反汇编处如果有CC断点，要看看先能不能复原
		invoke DisasmLineEx, addr @bufCode, 16, @dwCurAddr, addr @szBufAsm
		mov @dwCodeLen, eax
		invoke crt_printf, offset g_szDisasmFmt, @dwCurAddr, addr @szBufAsm
		
		mov eax,@dwCodeLen
		add @dwCurAddr,eax
		inc @nIdx
	.endw
	
	mov eax,@dwCurAddr  ;第9条指令的地址
	
	ret
	
Disasm8Lines endp
	
InputCommand proc uses esi
LOCAL @dwBpAddr:DWORD
LOCAL @byteOld:DWORD
LOCAL @szBufAsm[64]:BYTE
LOCAL @dwEip:DWORD
LOCAL @dwBytesReadWrite:DWORD
LOCAL @dwCodeLen:DWORD
LOCAL @bufCode[16]:BYTE
LOCAL @dwCurPBpAddr:DWORD
LOCAL @dwBhType:DWORD
LOCAL @dwBhAddr:DWORD
LOCAL @dwBhLen:DWORD
LOCAL @dwBMType:DWORD
LOCAL @dwBMAddr:DWORD
LOCAL @dwBMLen:DWORD
LOCAL @szBufReg[64]:BYTE
LOCAL @dwRegVal2Change:DWORD
LOCAL @dwEditDataAddr:DWORD
LOCAL @dwEditVal:DWORD       ;实际只使用字节
LOCAL @hStdIn:HANDLE
LOCAL @pExportScpFile:DWORD

	
	
	invoke RtlZeroMemory, addr @szBufAsm, 64
	
	;输入命令之前，显示一条反汇编
	invoke GetEip
	mov @dwEip, eax
	
	invoke ReadProcessMemory, g_hProc, @dwEip, addr @bufCode, 16, addr @dwBytesReadWrite
	;此时反汇编处如果有CC断点，要看看先能不能复原
	invoke DisasmLineEx, addr @bufCode, 16, @dwEip, addr @szBufAsm
	mov @dwCodeLen, eax
	invoke crt_printf, offset g_szDisasmFmt, @dwEip, addr @szBufAsm
	
	invoke ShowAllRegs
	
	.IF g_bIsGoRet
	    mov g_bIsGoRet,FALSE        ;一旦触发断点，取消执行到返回
	.endif
	
	
	.IF g_bIsTraceOn        ;处于Trace状态,仍然调用了输入指令，必然是碰到了断点 / Trace结束
	    mov g_bIsTraceOn,FALSE
	    ;关闭文件
	    fn crt_puts, "Trace Finished!"
	    invoke crt_fclose,g_pTraceFile
	.endif
	
	
	.while TRUE 
		;接受命令
	        invoke crt_printf,offset g_szPromptUserInput
		.IF g_bIsScpLoaded
		    invoke crt_fgets, offset g_szCommand,256,g_pLoadScpFile
		    .IF eax == NULL
		        mov g_bIsScpLoaded,FALSE
		        jmp LB_GETS
		    .endif
		    invoke crt_printf,offset g_szCommand
		    ;移除最后的\n
		    invoke crt_strchr,offset g_szCommand,0ah
		    .IF eax
		        mov byte ptr [eax],0
		    .endif
		    
		.ELSE
		LB_GETS:
		    invoke crt_gets, offset g_szCommand
		    ;记录指令
		    .IF g_bIsRecording && !(g_szCommand[0] == 'e' && g_szCommand[1] == 's' && g_szCommand[2] == ' ')
		        mov esi,offset g_arrSzCmds
		        mov eax,g_nTotalCmds
		        imul eax,256
		        add esi,eax
		        invoke crt_strcpy,esi,offset g_szCommand
		        inc g_nTotalCmds
		    .endif
		.endif
		
		
		.IF !(g_szCommand[0] == 'u' && g_szCommand[1] == 0)
			mov g_bIsLastTimeDisasm,FALSE
		.ENDIF
		
		.IF !(g_szCommand[0] == 'd' && g_szCommand[1] == 'd')
			mov g_bIsLastTimeDD,FALSE
		.ENDIF
		
		;解析命令码
		.if g_szCommand[0] == 'b' && g_szCommand[1] == 'p'
			;bp xxxxx 一般断点命令
			;解析参数 - 地址
			invoke crt_strtoul, offset g_szCommand+3, NULL, 16
			.if eax == 0 || eax == -1
				;命令出错，重新输入
				invoke crt_printf, offset g_szCommandErrTip
				.continue
			.endif
			
			mov @dwBpAddr,eax
			;设置断点
			invoke SetBp,eax
			mov @byteOld,eax
			;保存断点到断点表
			invoke SaveNormalBpToTable,@byteOld,@dwBpAddr
		.elseif 	g_szCommand[0] == 'b' && g_szCommand[1] == 'l'
			; bl 列出所有断点
			invoke ListAllBps
		.elseif 	g_szCommand[0] == 'b' && g_szCommand[1] == 'c'
			; bc xx 清除xx号断点,十进制
			;解析参数 - 序号
			.IF  g_szCommand[3] == '0'
				mov eax,0
			.ELSE
				invoke crt_strtoul, offset g_szCommand+3, NULL, 10
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
			.endif
			invoke ClearNormalBp,eax
		.ELSEIF g_szCommand[0]== 't' && g_szCommand[1] == 'r' && g_szCommand[2] == 'a' && g_szCommand[3] == 'c'&& g_szCommand[4] == 'e'    ;trace
	                invoke crt_strtoul, offset g_szCommand+6, NULL, 16
			.if eax == 0 || eax == -1
			;命令出错，重新输入
			    invoke crt_printf, offset g_szCommandErrTip
			    .continue
			.endif
			invoke SetTrace,eax
			ret
		.ELSEIF g_szCommand[0] == 't'           ;单步步入
			invoke SetTF
			mov g_bIsStepIntoSingleStep,TRUE
			ret
		.ELSEIF g_szCommand[0] == 'p'           ;单步步过
			invoke SetStepOver
			ret
		.ELSEIF g_szCommand[0] == 'b' && g_szCommand[1] == 'h' &&   g_szCommand[2] == 'l';显示硬件断点
			invoke ListAllHardwareBps
		.ELSEIF g_szCommand[0] == 'b' && g_szCommand[1] == 'h' &&   g_szCommand[2] == 'c';清除硬件断点 
			; bhc xx 清除xx号断点,十进制
			;解析参数 - 序号
			.IF  g_szCommand[4] == '0'
				mov eax,0
			.ELSE
				invoke crt_strtoul, offset g_szCommand+4, NULL, 10
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
			.endif
			invoke ClearHardwareBp,eax
		.ELSEIF g_szCommand[0] == 'b' && g_szCommand[1] == 'h'  ;硬件断点
			;bh type ADDR len
			;解析参数 - 断点类型
			.IF g_szCommand[3] == 'e' ;执行断点
				mov @dwBhType,BHT_EXECUTE
			.ELSEIF g_szCommand[3] == 'a'   ;访问断点
				mov @dwBhType,BHT_ACCESS
			.ELSEIF g_szCommand[3] == 'w'   ;写入断点
				mov @dwBhType,BHT_WRITE
			.ELSE
				;命令出错，重新输入
				invoke crt_printf, offset g_szCommandErrTip
				.continue
			.endif
			;解析参数 - 地址
			invoke crt_strtoul, offset g_szCommand+5, NULL, 16
			.if eax == 0 || eax == -1
				;命令出错，重新输入
				invoke crt_printf, offset g_szCommandErrTip
				.continue
			.endif
			mov @dwBhAddr,eax
			;解析参数 - 长度
			mov @dwBhLen,0       ;长度与手册保持一致
			.IF @dwBhType != BHT_EXECUTE
				invoke crt_strtoul, offset g_szCommand+14, NULL, 16
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.ELSEIF eax == 1
					mov @dwBhLen,BHL_BYTE
				.ELSEIF eax == 2
					mov @dwBhLen,BHL_WORD
				.ELSEIF eax == 4
					mov @dwBhLen,BHL_DWORD
				.ELSE
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
			.endif
			invoke SetBH,@dwBhType,@dwBhAddr,@dwBhLen
		.ELSEIF    g_szCommand[0] == 'b' && g_szCommand[1] == 'm' && g_szCommand[2] == 'l'  ;内存断点列表
			invoke ListAllMemBp
		.ELSEIF    g_szCommand[0] == 'b' && g_szCommand[1] == 'm' && g_szCommand[2] == 'c'  ;删除内存断点
			; bmc xx 清除xx号断点,十进制
			;解析参数 - 序号
			.IF  g_szCommand[4] == '0'
				mov eax,0
			.ELSE
				invoke crt_strtoul, offset g_szCommand+4, NULL, 10
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
			.endif
			invoke ClearMemBp,eax
		.ELSEIF    g_szCommand[0] == 'b' && g_szCommand[1] == 'm' && g_szCommand[2] == 'p' && g_szCommand[3] == 'l'  ;内存断点分页信息	
			invoke ListBMIDPageTable
		.ELSEIF    g_szCommand[0] == 'b' && g_szCommand[1] == 'm'  ;内存断点
			;bm type ADDR len
			;解析参数 - 断点类型
			.IF g_szCommand[3] == 'a'   ;访问内存断点
				mov @dwBMType,BMT_ACCESS
			.ELSEIF g_szCommand[3] == 'w'   ;写入断点
				mov @dwBMType,BMT_WRITE
			.ELSE
				;命令出错，重新输入
				invoke crt_printf, offset g_szCommandErrTip
				.continue
			.endif
			;解析参数 - 地址
			invoke crt_strtoul, offset g_szCommand+5, NULL, 16
			.if eax == 0 || eax == -1
				;命令出错，重新输入
				invoke crt_printf, offset g_szCommandErrTip
				.continue
			.endif
			mov @dwBMAddr,eax
			;解析参数 - 长度
			mov @dwBMLen,0       
			invoke crt_strtoul, offset g_szCommand+14, NULL, 16
			.if eax == 0 || eax == -1
				;命令出错，重新输入
				invoke crt_printf, offset g_szCommandErrTip
				.continue
			.endif
			mov @dwBMLen,eax  
			invoke SetBM,@dwBMType,@dwBMAddr,@dwBMLen
		.ELSEIF     g_szCommand[0] == 'u'
			.IF g_szCommand[1] == 0
				;只有U
				.IF g_bIsLastTimeDisasm
					invoke Disasm8Lines,g_dwAddrToContinueDisasm 
					mov g_dwAddrToContinueDisasm,eax
				.ELSE
					invoke GetEip
					invoke Disasm8Lines,eax
					mov g_dwAddrToContinueDisasm,eax
				.endif
			.ELSE
				;U+Addr
				invoke crt_strtoul, offset g_szCommand+2, NULL, 16
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
				invoke Disasm8Lines,eax
				mov g_dwAddrToContinueDisasm,eax
			.endif
			
			mov g_bIsLastTimeDisasm,TRUE
			.continue
		.ELSEIF     g_szCommand[0] == 'd' && g_szCommand[1] == 'u' && g_szCommand[2] == 'm'&& g_szCommand[3] == 'p'
			invoke DumpCurProcess
		.ELSEIF     g_szCommand[0] == 'g' && g_szCommand[1] == 'r' && g_szCommand[2] == 'e'&& g_szCommand[3] == 't'
		        invoke SetGoRet
		        ret
		.elseif 	g_szCommand[0] == 'g'
			.IF g_szCommand[1] == 0
				ret
			.ELSEIF g_szCommand[1] == ' '
				;G+Addr
				invoke crt_strtoul, offset g_szCommand+2, NULL, 16
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
				;在该地址设置临时断点
				mov @dwCurPBpAddr, eax
				invoke SetBp, @dwCurPBpAddr
				mov @byteOld,eax
				;保存断点到断点表
				invoke SaveStepOverBpToTable,@byteOld,@dwCurPBpAddr
				
				ret
			.endif
		.ELSEIF    g_szCommand[0] == 'm' && g_szCommand[1] == 'l'
			invoke ListAllModules
		.elseif 	g_szCommand[0] == 'r'
			.IF g_szCommand[1] == 0
				invoke ShowAllRegs
		        .ELSE
		            ;r+reg+Val
		            fn crt_sscanf,offset g_szCommand+2,"%s %X",addr @szBufReg,addr @dwRegVal2Change
		            .IF eax!=2
		                invoke crt_printf, offset g_szCommandErrTip
				.continue
		            .endif
		            
		            invoke SetRegVal,addr @szBufReg,@dwRegVal2Change
		            .IF eax == FALSE
		                invoke crt_printf, offset g_szCommandErrTip
				.continue
		            .endif
			.endif
		.elseif 	g_szCommand[0] == 'd'	&& g_szCommand[1] == 'd' 
		        .IF g_szCommand[2] == 0
				;只有dd
				.IF g_bIsLastTimeDD
					invoke DispData8Lines,g_dwAddrToContinueDD
					mov g_dwAddrToContinueDD,eax
				.ELSE
					invoke GetEip
					invoke DispData8Lines,eax
					mov g_dwAddrToContinueDD,eax
				.endif
			.ELSE
				;dd+Addr
				invoke crt_strtoul, offset g_szCommand+2, NULL, 16
				.if eax == 0 || eax == -1
					;命令出错，重新输入
					invoke crt_printf, offset g_szCommandErrTip
					.continue
				.endif
				invoke DispData8Lines,eax
				mov g_dwAddrToContinueDD,eax
			.endif
			
			mov g_bIsLastTimeDD,TRUE
			.continue
		.ELSEIF     g_szCommand[0] == 'e' && g_szCommand[1] == ' '
		        fn crt_sscanf,offset g_szCommand+2,"%p %02X",addr @dwEditDataAddr,addr @dwEditVal
		        .IF eax!=2
		            ;命令出错，重新输入
			    invoke crt_printf, offset g_szCommandErrTip
			    .continue
		        .endif
		        
		        invoke EditDataAtAddr,@dwEditDataAddr,@dwEditVal
		 .ELSEIF     g_szCommand[0] == 'l' && g_szCommand[1] == 's' && g_szCommand[2] == ' ' 
		        invoke crt_strcpy,offset g_szLoadScpName,offset g_szCommand+3
		        fn crt_fopen,offset g_szLoadScpName,"r"
		        .IF eax == 0
		            fn crt_puts,"File Doesn't Exist!"
		            .CONTINUE
		        .endif
		        mov g_pLoadScpFile,eax
		        mov g_bIsScpLoaded,TRUE
		 .ELSEIF     g_szCommand[0] == 'e' && g_szCommand[1] == 's' && g_szCommand[2] == ' ' 
		        fn crt_fopen,offset g_szCommand+3,"w"
		        mov @pExportScpFile,eax
		       invoke ExportScript,@pExportScpFile
		        
		
		.ELSEIF     g_szCommand[0] == 'q'
			invoke ExitProcess,0
			ret
		.endif
	LB_INVALID_INPUT:
	        	
	.endw
	
	ret
	
InputCommand endp
	
OnOutputDBGString proc uses esi ebx
LOCAL @szBuf[MAX_PATH]:BYTE
LOCAL @szBufW[MAX_PATH]:WORD
LOCAL @dwBytesReaded:DWORD
	
	invoke RtlZeroMemory,addr @szBuf, MAX_PATH
	
	lea esi, g_de.u.DebugString
	assume esi:ptr OUTPUT_DEBUG_STRING_INFO
	
	movzx ebx,[esi].nDebugStringiLength
	
	;读取字符串
	.IF [esi].fUnicode
		invoke ReadProcessMemory,g_hProc, [esi].lpDebugStringData, addr @szBufW, ebx, addr @dwBytesReaded
		.if !eax
			ret
		.endif
		invoke WideCharToMultiByte, CP_ACP, 0,addr @szBufW, -1, addr @szBuf, MAX_PATH,NULL,NULL
	.ELSE
		invoke ReadProcessMemory,g_hProc, [esi].lpDebugStringData, addr @szBuf, ebx, addr @dwBytesReaded
		.if !eax
			ret
		.endif
	.ENDIF
	
	;输出
	invoke crt_printf, offset g_szOutputDBGStrFmt, addr @szBuf
	
	ret
OnOutputDBGString endp
	
OnExcept proc uses esi edi
LOCAL @dwStatus:DWORD
LOCAL  @ctx:CONTEXT
LOCAL @bShouldInputCMD:DWORD
LOCAL @dwDR6LOW4:DWORD
LOCAL @dwOldProtect:DWORD
LOCAL @szBufAsm[64]:BYTE
LOCAL @dwEip:DWORD
LOCAL @dwBytesReadWrite:DWORD
LOCAL @dwCodeLen:DWORD
LOCAL @bufCode[16]:BYTE
	
	lea esi, g_de.u.Exception.pExceptionRecord
	assume esi:ptr EXCEPTION_RECORD
	
	mov @dwStatus, DBG_CONTINUE
	mov @bShouldInputCMD,FALSE
	
	.if [esi].ExceptionCode == EXCEPTION_BREAKPOINT ;80000003 断点异常
		.if g_bIsSysBp          ;第一次必然为系统断点
			invoke crt_printf, offset g_szSysBpTip
			mov g_bIsSysBp,FALSE
			invoke InputCommand
		.else
			;还原指令
			invoke RestoreBp,[esi].ExceptionAddress
		.endif
		
		
	.elseif [esi].ExceptionCode == EXCEPTION_SINGLE_STEP    ;80000004 单步异常
	        .IF g_bIsGoRet
		    invoke JudgeIsRetReached
		    .IF eax
		        mov g_bIsGoRet,FALSE
		        mov @bShouldInputCMD,TRUE
		    .ELSE 
		        invoke SetTraceOver
		        mov @bShouldInputCMD,FALSE                      ;执行到返回引发的单步，不需要接受
		    .endif
		.endif
	
		.IF g_bIsTraceOn
		    ;输入命令之前，显示一条反汇编
			invoke GetEip
			mov @dwEip, eax
			
			invoke ReadProcessMemory, g_hProc, @dwEip, addr @bufCode, 16, addr @dwBytesReadWrite
			;此时反汇编处如果有CC断点，要看看先能不能复原
			invoke DisasmLineEx, addr @bufCode, 16, @dwEip, addr @szBufAsm
			mov @dwCodeLen, eax
			;写入文件
			invoke crt_fprintf,g_pTraceFile,offset g_szTraceFmt,@dwEip,addr @szBufAsm
			;比较是否结束
			mov eax,@dwEip
			.IF eax == g_dwTraceDstAddr
				mov @bShouldInputCMD,TRUE		;此处不修改,一旦调用输入命令，则Trace必须停止
			.ELSE
				invoke SetTF
				mov @bShouldInputCMD,FALSE
			.ENDIF
		.ENDIF
		
		;本次可能被删除，不用再设置断点
		.IF g_bIsNormallBpSingleStep
			mov g_bIsNormallBpSingleStep,FALSE
			invoke GetNormalBpAddrInTable,g_dwLastBpAddr
			.IF eax !=0
				invoke SetBp,g_dwLastBpAddr   ;这里的一定是上一次断点的地址
			.endif
		.endif
		
		.IF g_bIsStepIntoSingleStep == TRUE
			mov g_bIsStepIntoSingleStep,FALSE
			mov @bShouldInputCMD,TRUE
			
		.endif
		
		.IF g_bIsHardwareBpSingleStep == TRUE
			mov g_bIsHardwareBpSingleStep,FALSE
			invoke GetHardWareBpAddrInTable,g_dwLastHardWareBpAddr
			.IF eax!=0      ;还没有被删除
				invoke GetContext, addr @ctx
				mov eax,g_dwDR6LToRestore
				or @ctx.iDr7,eax
				invoke SetContext, addr @ctx
			.endif
			
		.endif
		
		.IF g_bIsMemBpSingleStep == TRUE
			mov g_bIsMemBpSingleStep,FALSE
			;重设内存属性
			;先查询是否还在页表
			invoke FindBMPageTableByPageAddr,g_dwLastPageAddr
			.IF eax!=0
				invoke VirtualProtectEx, g_hProc, g_dwLastPageAddr, 1000h, PAGE_NOACCESS, addr @dwOldProtect
			.endif
		.endif
		
		;是否是hit硬件断点引发的单步异常
		invoke GetContext, addr @ctx
		mov eax,@ctx.iDr6
		and eax,0Fh     ;取低四位
		mov @dwDR6LOW4,eax
		.IF @dwDR6LOW4!=0                       ;是硬件断点引发的且是执行断点
			;如果不是执行断点
			
			;先暂时取消硬件断点,设置TF位置,再次引发中断时判断恢复
			;记住L/G的值
			.IF @dwDR6LOW4 == 0001b
				.IF (@ctx.iDr7 & 00030000h)    ;非执行断点
					jmp LB_1
				.endif
				and @ctx.iDr7,0FFFFFFFEh
				mov g_dwDR6LToRestore,00000001b
			.ELSEIF @dwDR6LOW4 == 0010b
				.IF (@ctx.iDr7 & 00300000h)    ;非执行断点
					jmp LB_1
				.endif
				and @ctx.iDr7,0FFFFFFFBh
				mov g_dwDR6LToRestore,00000100b
			.ELSEIF @dwDR6LOW4 == 0100b
				.IF (@ctx.iDr7 & 03000000h)    ;非执行断点
					jmp LB_1
				.endif
				and @ctx.iDr7,0FFFFFFEFh
				mov g_dwDR6LToRestore,00010000b
			.ELSEIF @dwDR6LOW4 == 1000b
				.IF (@ctx.iDr7 & 30000000h)    ;非执行断点
					jmp LB_1
				.endif
				and @ctx.iDr7,0FFFFFFBFh
				mov g_dwDR6LToRestore,01000000b
			.ENDIF
			mov eax,@ctx.regEip
			mov g_dwLastHardWareBpAddr,eax
			or @ctx.regFlag, 100h   ;设置TF位置
			mov g_bIsHardwareBpSingleStep,TRUE ;再次引发中断时判断恢复
LB_1:
			invoke SetContext,addr @ctx
			invoke crt_printf, offset g_szBhTip, @ctx.regEip
			mov @bShouldInputCMD,TRUE
		.endif
		
		
		
		.IF @bShouldInputCMD
			invoke InputCommand
		.endif
	.ELSEIF [esi].ExceptionCode == EXCEPTION_ACCESS_VIOLATION
		;判断该分页是否在分页表中
		mov eax,[esi].ExceptionInformation[1*4]     ;获取触发异常的访问地址
		and eax,0FFFFF000h                                  ;拿分页地址
		invoke FindBMPageTableByPageAddr,eax    ;查找分页
		.IF !eax        ;未找到
			mov @dwStatus,DBG_EXCEPTION_NOT_HANDLED
			jmp LB_END
		.endif
		;找到了，恢复属性 ,设置TF位，用于后面单步重设断点
		mov edi,eax
		assume edi:ptr tagBMPage
		invoke VirtualProtectEx,g_hProc, [edi].m_dwPageAddr, 01000h,[edi].m_dwOldProc, addr @dwOldProtect
		invoke SetTF
		mov g_bIsMemBpSingleStep,TRUE
		push [edi].m_dwPageAddr
		pop g_dwLastPageAddr    ;记录本次恢复的页面地址，用于后面单步重设断点
		
		;invoke GetEip
		
		;判断是否命中内存断点（判断范围和类型）
		;判断范围
		invoke FindAddrInWhichBMBp,[esi].ExceptionInformation[1*4]
		.IF !eax
			;未命中任何范围
			jmp LB_END
		.ENDIF
		;判断类型
		mov edi,eax
		assume edi:ptr tagMemBp
		mov eax,[edi].m_dwType
		;命中
		.IF eax == BMT_ACCESS
			invoke crt_printf,offset g_szBMAccessTip,[esi].ExceptionInformation[1*4]
		.ELSEIF eax == BMT_WRITE && eax == [esi].ExceptionInformation[0*4]
			invoke crt_printf,offset g_szBMWriteTip,[esi].ExceptionInformation[1*4]
		.ELSE
		        jmp LB_END
		.ENDIF
		invoke InputCommand
		
	.endif
	
LB_END:
	mov eax,@dwStatus
	
	ret
	
OnExcept endp
	
	
OnLoadDll proc uses esi
LOCAL @szBuf[MAX_PATH]:BYTE
LOCAL @szBufW[MAX_PATH]:WORD
LOCAL @dwAddr:DWORD
LOCAL @dwBytesReaded:DWORD
	
	invoke RtlZeroMemory,addr @szBuf, MAX_PATH
	
	lea esi, g_de.u.LoadDll
	assume esi:ptr LOAD_DLL_DEBUG_INFO
	
	;读取地址
	invoke ReadProcessMemory,g_hProc, [esi].lpImageName, addr @dwAddr, size @dwAddr, addr @dwBytesReaded
	.if !eax
		ret
	.endif
	
	.if [esi].fUnicode
		invoke ReadProcessMemory, g_hProc, @dwAddr, addr @szBufW, MAX_PATH*2, addr @dwBytesReaded
		.if !eax
			ret
		.endif
		
		invoke WideCharToMultiByte, CP_ACP, 0,addr @szBufW, -1, addr @szBuf, MAX_PATH,NULL,NULL
	.else
		invoke ReadProcessMemory, g_hProc, @dwAddr, addr @szBuf, MAX_PATH, addr @dwBytesReaded
		.if !eax
			ret
		.endif
	.endif
	
	;输出
	invoke crt_printf, offset g_szLoadDllFmt, [esi].lpBaseOfDll, addr @szBuf
	
	ret
	
OnLoadDll endp
	
OnCreateProcess proc
LOCAL @byteOld:DWORD
	push g_de.u.CreateProcessInfo.lpBaseOfImage
	pop g_dwImageBase
	push g_de.u.CreateProcessInfo.lpStartAddress
	pop g_dwOEP
	
	
	
	invoke SetBp, g_dwOEP
	mov @byteOld,eax
	;保存断点到断点表
	invoke SaveStepOverBpToTable,@byteOld,g_dwOEP
	
	
	ret
	
OnCreateProcess endp	
main proc
LOCAL @si:STARTUPINFO
LOCAL @pi:PROCESS_INFORMATION
LOCAL @dwStatus:DWORD
	
	invoke GetCL,1,offset g_szFileName
	
	invoke RtlZeroMemory, addr @si, size @si
	invoke RtlZeroMemory, addr @pi, size @pi
	
	
	
	;建立调试会话
	invoke CreateProcess, NULL, offset g_szFileName, NULL, NULL, FALSE, \
	DEBUG_ONLY_THIS_PROCESS OR CREATE_NEW_CONSOLE, NULL, NULL, addr @si, addr @pi
	;check 。。。。
	mov eax, @pi.hProcess
	mov g_hProc, eax
	
	
	;循环接受调试事件
	.while TRUE
		mov @dwStatus, DBG_CONTINUE
		invoke RtlZeroMemory,offset g_de, size g_de
		invoke WaitForDebugEvent, offset g_de, INFINITE
		
		;判断，处理
		.if g_de.dwDebugEventCode == EXCEPTION_DEBUG_EVENT
			;invoke crt_printf, offset g_szFmt, offset g_szEXCEPTION_DEBUG_EVENT
			invoke OnExcept
			mov @dwStatus, eax
		.elseif g_de.dwDebugEventCode == CREATE_THREAD_DEBUG_EVENT
			invoke crt_printf, offset g_szFmt, offset g_szCREATE_THREAD_DEBUG_EVENT
		.elseif g_de.dwDebugEventCode == CREATE_PROCESS_DEBUG_EVENT
			invoke crt_printf, offset g_szFmt, offset g_szCREATE_PROCESS_DEBUG_EVENT
			invoke OnCreateProcess
		.elseif g_de.dwDebugEventCode == EXIT_THREAD_DEBUG_EVENT
			invoke crt_printf, offset g_szFmt, offset g_szEXIT_THREAD_DEBUG_EVENT
		.elseif g_de.dwDebugEventCode == EXIT_PROCESS_DEBUG_EVENT
			invoke crt_printf, offset g_szFmt, offset g_szEXIT_PROCESS_DEBUG_EVENT
		.elseif g_de.dwDebugEventCode == LOAD_DLL_DEBUG_EVENT
			;invoke crt_printf, offset g_szFmt, offset g_szLOAD_DLL_DEBUG_EVENT
			invoke OnLoadDll
		.elseif g_de.dwDebugEventCode == UNLOAD_DLL_DEBUG_EVENT
			invoke crt_printf, offset g_szFmt, offset g_szUNLOAD_DLL_DEBUG_EVENT
		.elseif g_de.dwDebugEventCode == OUTPUT_DEBUG_STRING_EVENT
			;invoke crt_printf, offset g_szFmt, offset g_szOUTPUT_DEBUG_STRING_EVENT
			invoke OnOutputDBGString
		.endif
		
		;提交处理结果
		invoke ContinueDebugEvent, g_de.dwProcessId, g_de.dwThreadId, @dwStatus
	.endw
	
	
	ret
	
main endp
	
	
	
ENTRY:
	invoke main
	invoke ExitProcess, 0
end ENTRY