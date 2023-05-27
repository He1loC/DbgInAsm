
	include windows.inc
	include kernel32.inc
	include user32.inc
	include Comctl32.inc
	include shell32.inc
	include msvcrt.inc
	include psapi.inc
	include \masm32\macros\macros.asm  
	include masm32.inc
	
	
	
	includelib kernel32.lib
	includelib user32.lib
	includelib Comctl32.lib
	includelib shell32.lib
	includelib msvcrt.lib
	includelib capstoneplus.lib
	includelib psapi.lib
	includelib shell32.lib
	includelib masm32.lib
	
	
MODULEINFO	struct 
    lpBaseOfDll	LPVOID	?
    SizeOfImage	DWORD	?
    EntryPoint	LPVOID	?
MODULEINFO	ends
	
	InputCommand proto
	
	DisasmLine proto code:LPBYTE , nCodeSize:DWORD , nAddr:DWORD , szAsm:LPSTR
	DisasmLineEx proto pCode:LPBYTE , nCodeSize:DWORD , dwAddr:DWORD , pszAsm:LPSTR
	
	SetBp proto dwAddr:DWORD
	
	
	SetStepOver proto
	
	
	SetTraceOver proto
	
	SetTF proto
	DecEip proto
	GetEip proto
	GetContext proto pCtx:ptr CONTEXT 
	SetContext proto pCtx:ptr CONTEXT 
	IsTwoAddrOverlapped proto dwAddr1:DWORD,dwLen1:DWORD,dwAddr2:DWORD,dwLen2:DWORD
	
	
	FindBMPageTableByPageAddr proto dwPageAddr:DWORD
	FindIDPageTableAddrByID proto dwID:DWORD
	
	AddBMPageTable proto dwPageAddr:DWORD
	AddBMIDPageTable proto dwID:DWORD,dwPageAddr:DWORD
	AddBMBpTable proto dwAddr:DWORD,dwLen:DWORD,dwType:DWORD
	
	DelBMPageTableByPageAddr proto dwPageAddr:DWORD
	DeIIDPageTableAddrByAddr proto dwAddr:DWORD
	DelBMBpTableByID proto dwID:DWORD
	
	GetNormalBpAddrInTable  proto dwAddr:DWORD
	GetStepOverBpAddrInTable  proto dwAddr:DWORD
	SaveStepOverBpToTable proto byteOld:DWORD,dwBpAddr:DWORD
	
	
	BHT_EXECUTE EQU 0
	BHT_ACCESS EQU 3
	BHT_WRITE   EQU 1
	
	BHL_BYTE EQU 0
	BHL_WORD EQU 1
	BHL_RESERVED EQU 2
	BHL_DWORD EQU 3
	
	BMT_READ EQU 0
	BMT_WRITE EQU 1
	BMT_ACCESS EQU 2
	
	
tagNormalBp struct
	m_dwAddr  DWORD 0
	m_byteOld  byte 0
	m_bIsEnabled byte 0         ;TODO 是否启用断点
tagNormalBp ends
	
tagStepOverBp struct
	m_dwAddr  DWORD 0
	m_byteOld  byte 0
	m_bUnused byte 0         
tagStepOverBp ends
	
tagHardwareBp struct
	m_dwIsUsed DWORD FALSE
	m_dwAddr  DWORD 0
	m_dwType DWORD 0
	m_dwLen  DWORD  0
tagHardwareBp ends

tagMemBp struct							;内存断点表表项
	m_dwID      DWORD 0					;ID
	m_dwAddr  DWORD 0					;断点地址
	m_dwLen    DWORD 0					;长度
	m_dwType   DWORD 0					;类型
tagMemBp ends

tagBMIDPage struct					;内存断点ID-页表表项	
	m_dwID DWORD 0					;ID
	m_dwPageAddr DWORD 0			;page Addr
tagBMIDPage ends

tagBMPage struct
	m_dwPageAddr DWORD 0			;page Addr
	m_dwOldProc	DWORD  0			;原有属性
	m_dwNumOfBp DWORD 0                     ;当前分页拥有的断点个数
tagBMPage ends