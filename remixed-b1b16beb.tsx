import { useState } from "react";

const C = {
  gold:"#C8860A",goldLight:"#E8A020",goldSurface:"#FFF8EC",
  cream:"#FAF6F0",charcoal:"#1A1A2E",mid:"#2D2D44",
  slate:"#6B7280",green:"#10B981",red:"#EF4444",
  blue:"#3B82F6",divider:"#EDE8E0",white:"#FFFFFF",
  greenSurface:"#ECFDF5",redSurface:"#FEF2F2",blueSurface:"#EEF2FF",
};
const font="'Cairo',sans-serif";

// ─── SVG ICON SYSTEM ──────────────────────────────────────────────────────────
const paths = {
  home: "M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V9.5z M9 21V12h6v9",
  building: "M6 2h12a1 1 0 0 1 1 1v19H5V3a1 1 0 0 1 1-1z M9 7h2m4 0h-2M9 11h2m4 0h-2M9 15h2m4 0h-2M10 21v-4h4v4",
  users: "M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2 M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z M23 21v-2a4 4 0 0 0-3-3.87 M16 3.13a4 4 0 0 1 0 7.75",
  wallet: "M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5z M16 12h.01",
  plus: "M12 5v14M5 12h14",
  arrowLeft: "M19 12H5M12 5l-7 7 7 7",
  edit: "M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7 M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z",
  trash: "M3 6h18M8 6V4h8v2M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6",
  bed: "M3 7v13M21 7v13M3 12h18M3 7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4",
  door: "M5 3h14a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z M15 12h.01",
  phone: "M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.15 9.8a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.06 0H6a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.09 7.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.9.387 1.84.656 2.81.7A2 2 0 0 1 21 14.92z",
  bell: "M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9 M13.73 21a2 2 0 0 1-3.46 0",
  whatsapp: "M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2z M8.5 13.5s1 1.5 2 2 3.5.5 5-1.5-1-4-3-3-3 2-2 2",
  check: "M20 6L9 17l-5-5",
  warning: "M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z M12 9v4M12 17h.01",
  eye: "M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z M12 12a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
  location: "M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z M12 10a2 2 0 1 0 0-4 2 2 0 0 0 0 4z",
  calendar: "M19 4H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z M16 2v4M8 2v4M3 10h18",
  money: "M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2z M12 6v2m0 8v2M8 12h8M9.5 8.5h5a1.5 1.5 0 0 1 0 3h-3a1.5 1.5 0 0 0 0 3h5",
  exit: "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4 M16 17l5-5-5-5M21 12H9",
  close: "M18 6L6 18M6 6l12 12",
  chevronDown: "M6 9l6 6 6-6",
  chevronRight: "M9 18l6-6-6-6",
  person: "M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z",
  star: "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z",
};

const Ic = ({ n, size=18, color="currentColor", strokeWidth=1.8 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round">
    {paths[n]?.split(" M").map((seg,i) => <path key={i} d={i===0?seg:"M"+seg}/>)}
  </svg>
);

// ─── DATA ─────────────────────────────────────────────────────────────────────
const initApts = [
  {
    id:"a1",name:"شقة الحديقة - مبنى ٣",area:"الحي السادس",address:"٢٤ شارع المحور، الحديقة",floor:2,
    rooms:[
      {id:"r1",name:"غرفة ١",beds:[
        {id:"b1",label:"سرير A",price:1250,tenant:{name:"أحمد خالد",phone:"01012345678",since:"يناير ٢٠٢٥",rent:1250,paid:true}},
        {id:"b2",label:"سرير B",price:1250,tenant:{name:"سارة علي",phone:"01198765432",since:"فبراير ٢٠٢٥",rent:1250,paid:false}},
      ]},
      {id:"r2",name:"غرفة ٢",beds:[
        {id:"b3",label:"سرير A",price:1300,tenant:{name:"محمد حسن",phone:"01555123456",since:"ديسمبر ٢٠٢٤",rent:1300,paid:true}},
        {id:"b4",label:"سرير B",price:1300,tenant:null},
      ]},
    ]
  },
  {
    id:"a2",name:"ستوديو دريم لاند",area:"دريم لاند",address:"كمبوند دريم لاند، مبنى ٧، شقة ١٢",floor:3,
    rooms:[
      {id:"r3",name:"الغرفة الرئيسية",beds:[
        {id:"b5",label:"سرير",price:3800,tenant:null},
      ]},
    ]
  },
  {
    id:"a3",name:"شقة المحور - ٤ غرف",area:"المحور",address:"شارع المحور الرئيسي، المحور المركزي",floor:1,
    rooms:[
      {id:"r4",name:"غرفة ١",beds:[
        {id:"b6",label:"سرير A",price:1100,tenant:{name:"عمر إبراهيم",phone:"01233334444",since:"يناير ٢٠٢٥",rent:1100,paid:true}},
        {id:"b7",label:"سرير B",price:1100,tenant:null},
      ]},
      {id:"r5",name:"غرفة ٢",beds:[
        {id:"b8",label:"سرير A",price:900,tenant:{name:"ياسمين فاروق",phone:"01066667777",since:"مارس ٢٠٢٥",rent:900,paid:true}},
        {id:"b9",label:"سرير B",price:900,tenant:null},
        {id:"b10",label:"سرير C",price:900,tenant:null},
      ]},
    ]
  },
];

const MONTHS = ["يناير ٢٠٢٥","فبراير ٢٠٢٥","مارس ٢٠٢٥","أبريل ٢٠٢٥","مايو ٢٠٢٥","يونيو ٢٠٢٥","ديسمبر ٢٠٢٤","نوفمبر ٢٠٢٤"];
const AREAS  = ["الحي السادس","الحي الأول","دريم لاند","المحور","بيفرلي هيلز","أرابيلا","الشيخ زايد"];

// ─── SHARED UI ────────────────────────────────────────────────────────────────
const Pill=({label,color=C.gold,bg=C.goldSurface,size=10})=>(
  <span style={{background:bg,color,fontSize:size,fontWeight:700,padding:"3px 9px",borderRadius:20,whiteSpace:"nowrap"}}>{label}</span>
);

const Btn=({label,onClick,color=C.gold,fill=true,small,disabled,style:s})=>(
  <button onClick={onClick} disabled={disabled} style={{
    background:fill?(disabled?"#D1D5DB":color):"transparent",
    color:fill?C.white:(disabled?C.slate:color),
    border:fill?"none":`1.5px solid ${disabled?C.slate:color}`,
    borderRadius:13,padding:small?"9px 16px":"14px 20px",
    fontFamily:font,fontWeight:700,fontSize:small?12:14,
    cursor:disabled?"not-allowed":"pointer",
    display:"inline-flex",alignItems:"center",justifyContent:"center",gap:6,
    opacity:disabled?0.6:1,...s
  }}>{label}</button>
);

const BackBtn=({onClick})=>(
  <button onClick={onClick} style={{background:C.white,border:`1px solid ${C.divider}`,cursor:"pointer",width:38,height:38,borderRadius:11,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
    <Ic n="arrowLeft" size={18} color={C.charcoal}/>
  </button>
);

const Field=({label,placeholder,value,onChange,type="text",select,options,prefix})=>(
  <div style={{marginBottom:14}}>
    <div style={{fontSize:12,fontWeight:600,color:C.charcoal,marginBottom:6}}>{label}</div>
    {select
      ?<select value={value} onChange={e=>onChange(e.target.value)} style={{width:"100%",padding:"12px 14px",borderRadius:12,border:`1.5px solid ${C.divider}`,fontFamily:font,fontSize:13,background:C.white,outline:"none",boxSizing:"border-box"}}>
        {options.map(o=><option key={o.v} value={o.v}>{o.l}</option>)}
      </select>
      :<div style={{position:"relative"}}>
        {prefix&&<span style={{position:"absolute",right:14,top:"50%",transform:"translateY(-50%)",fontSize:11,fontWeight:700,color:C.slate,pointerEvents:"none"}}>{prefix}</span>}
        <input value={value} onChange={e=>onChange(e.target.value)} placeholder={placeholder} type={type}
          style={{width:"100%",padding:"12px 14px",paddingRight:prefix?48:14,borderRadius:12,border:`1.5px solid ${value?C.gold:C.divider}`,fontFamily:font,fontSize:13,background:value?"#FFFBF3":C.white,outline:"none",boxSizing:"border-box",transition:"border 0.15s,background 0.15s"}}/>
      </div>
    }
  </div>
);

// Bottom sheet modal — scrollable body + optional sticky footer
const Sheet=({title,onClose,children,footer})=>(
  <div style={{position:"absolute",inset:0,background:"#0007",zIndex:100,display:"flex",alignItems:"flex-end"}} onClick={onClose}>
    <div onClick={e=>e.stopPropagation()} style={{background:C.cream,borderRadius:"26px 26px 0 0",width:"100%",maxHeight:"92%",display:"flex",flexDirection:"column",direction:"rtl",fontFamily:font}}>
      {/* Handle */}
      <div style={{display:"flex",justifyContent:"center",padding:"10px 0 0"}}>
        <div style={{width:36,height:4,borderRadius:4,background:C.divider}}/>
      </div>
      {/* Header */}
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"14px 22px 12px",borderBottom:`1px solid ${C.divider}`,flexShrink:0}}>
        <div style={{fontSize:17,fontWeight:800,color:C.charcoal}}>{title}</div>
        <button onClick={onClose} style={{width:32,height:32,borderRadius:99,background:C.divider,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center"}}>
          <Ic n="close" size={14} color={C.charcoal}/>
        </button>
      </div>
      {/* Scrollable body */}
      <div style={{flex:1,overflowY:"auto",padding:"18px 22px",minHeight:0}}>
        {children}
      </div>
      {/* Sticky footer */}
      {footer&&<div style={{padding:"12px 22px 28px",borderTop:`1px solid ${C.divider}`,flexShrink:0,background:C.cream}}>
        {footer}
      </div>}
    </div>
  </div>
);

// Progress bar steps
const Steps=({current,total})=>(
  <div style={{display:"flex",gap:6,marginBottom:16}}>
    {Array.from({length:total},(_,i)=>(
      <div key={i} style={{flex:1,height:4,borderRadius:4,background:i<=current?C.gold:C.divider,transition:"background 0.3s"}}/>
    ))}
  </div>
);

// ─── CALL REMINDER ────────────────────────────────────────────────────────────
const CallReminderToast=({tenant,onClose})=>(
  <div style={{position:"absolute",inset:0,background:"#0009",zIndex:200,display:"flex",alignItems:"center",justifyContent:"center",padding:24}} onClick={onClose}>
    <div onClick={e=>e.stopPropagation()} style={{background:C.white,borderRadius:24,padding:28,width:"100%",direction:"rtl",fontFamily:font,textAlign:"center"}}>
      <div style={{width:72,height:72,borderRadius:99,background:C.greenSurface,margin:"0 auto 16px",display:"flex",alignItems:"center",justifyContent:"center"}}>
        <Ic n="phone" size={32} color={C.green}/>
      </div>
      <div style={{fontSize:18,fontWeight:800,color:C.charcoal}}>تذكير بالإيجار</div>
      <div style={{fontSize:13,color:C.slate,marginTop:6,lineHeight:1.8}}>هتتصل بـ <strong style={{color:C.charcoal}}>{tenant.name}</strong><br/>عشان تذكره بإيجار الشهر ده</div>
      <div style={{background:C.goldSurface,border:`1.5px solid ${C.gold}44`,borderRadius:16,padding:"16px 20px",margin:"20px 0",fontSize:22,fontWeight:900,color:C.charcoal,letterSpacing:2}}>{tenant.phone}</div>
      <div style={{display:"flex",gap:10}}>
        <Btn label="إلغاء" fill={false} color={C.slate} onClick={onClose} style={{flex:1}}/>
        <Btn label="اتصل دلوقتي" color={C.green} onClick={onClose} style={{flex:2}}/>
      </div>
    </div>
  </div>
);

// ─── ADD TENANT WITH PICKER ───────────────────────────────────────────────────
// Step 0: Personal info  →  Step 1: Pick apt  →  Step 2: Pick bed  →  Step 3: Housing details
function AddTenantWithPickerModal({apts,onClose,onSave,preselectedApt=null}){
  const startStep = preselectedApt ? 2 : 0; // skip to apt pre-selected → pick bed
  const [step,setStep]=useState(0);
  const [name,setName]=useState("");
  const [phone,setPhone]=useState("");
  const [selAptId,setSelAptId]=useState(preselectedApt?.id||null);
  const [selRoomId,setSelRoomId]=useState(null);
  const [selBedId,setSelBedId]=useState(null);
  const [rent,setRent]=useState("");
  const [since,setSince]=useState("مارس ٢٠٢٥");

  const selApt=apts.find(a=>a.id===selAptId);
  const emptyBeds=selApt?selApt.rooms.flatMap(r=>r.beds.filter(b=>!b.tenant).map(b=>({...b,roomName:r.name,roomId:r.id}))):[];
  const selBed=emptyBeds.find(b=>b.id===selBedId);
  const totalSteps = preselectedApt ? 3 : 4;

  // What step number are we on for the progress bar (0-indexed)
  const progressStep = preselectedApt ? step - 1 : step; // if preselected, steps are 0=personal,1=bed,2=housing

  const stepTitles=["بياناته الشخصية","اختر الشقة","اختر السرير","بيانات السكن"];
  const canNext0 = name.trim() && phone.trim();
  const canSave  = rent.trim();

  const handleSave=()=>onSave({aptId:selAptId,roomId:selRoomId,bedId:selBedId,name,phone,rent:parseInt(rent),since,paid:true});

  // Compute current step label
  const displayStep = preselectedApt
    ? [0,2,3][step] // maps local 0,1,2 → title indices 0,2,3
    : step;

  const footer=(
    <>
      {/* Step 0 personal */}
      {step===0 && (
        <Btn label="التالي ←" onClick={()=>canNext0&&setStep(preselectedApt?2:1)} disabled={!canNext0} style={{width:"100%"}}/>
      )}
      {/* Step 1 apt picker — no footer button, tap to advance */}
      {/* Step 2 bed picker — no footer button, tap to advance */}
      {/* Step 3 housing details */}
      {step===3 && (
        <div style={{display:"flex",gap:10}}>
          <Btn label="← سابق" fill={false} color={C.slate} onClick={()=>setStep(2)} style={{flex:1}}/>
          <Btn label="حفظ الساكن" onClick={handleSave} disabled={!canSave} color={C.gold} style={{flex:2}}/>
        </div>
      )}
      {/* Preselected: step 1 = bed, step 2 = housing */}
      {preselectedApt && step===2 && (
        <div style={{display:"flex",gap:10}}>
          <Btn label="← سابق" fill={false} color={C.slate} onClick={()=>setStep(0)} style={{flex:1}}/>
          <Btn label="حفظ الساكن" onClick={handleSave} disabled={!canSave} color={C.gold} style={{flex:2}}/>
        </div>
      )}
    </>
  );

  return(
    <Sheet title={stepTitles[displayStep]||"إضافة ساكن"} onClose={onClose} footer={footer}>
      <Steps current={preselectedApt?step:step} total={preselectedApt?3:4}/>

      {/* STEP 0: Personal info */}
      {step===0&&(
        <div>
          <div style={{display:"flex",justifyContent:"center",marginBottom:20}}>
            <div style={{width:64,height:64,borderRadius:99,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center"}}>
              <Ic n="person" size={32} color={C.gold}/>
            </div>
          </div>
          <Field label="الاسم الكامل" placeholder="أحمد محمد" value={name} onChange={setName}/>
          <Field label="رقم التليفون" placeholder="01xxxxxxxxx" value={phone} onChange={setPhone} type="tel"/>
        </div>
      )}

      {/* STEP 1: Pick apartment (only if not preselected) */}
      {!preselectedApt&&step===1&&(
        <div>
          {apts.map(apt=>{
            const empty=apt.rooms.flatMap(r=>r.beds.filter(b=>!b.tenant)).length;
            return(
              <div key={apt.id} onClick={()=>{setSelAptId(apt.id);setStep(2);}}
                style={{background:C.white,border:`1.5px solid ${selAptId===apt.id?C.gold:C.divider}`,borderRadius:16,padding:16,marginBottom:10,cursor:"pointer",display:"flex",alignItems:"center",gap:12}}>
                <div style={{width:44,height:44,borderRadius:12,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  <Ic n="building" size={22} color={C.gold}/>
                </div>
                <div style={{flex:1}}>
                  <div style={{fontSize:14,fontWeight:800,color:C.charcoal}}>{apt.name}</div>
                  <div style={{fontSize:11,color:C.slate,marginTop:2,display:"flex",alignItems:"center",gap:4}}>
                    <Ic n="location" size={12} color={C.slate}/> {apt.area}
                  </div>
                </div>
                <Pill label={`${empty} فاضي`} color={empty>0?C.blue:C.slate} bg={empty>0?C.blueSurface:"#F3F4F6"} size={11}/>
              </div>
            );
          })}
        </div>
      )}

      {/* STEP 2: Pick bed */}
      {((!preselectedApt&&step===2)||(preselectedApt&&step===1))&&(
        <div>
          {preselectedApt&&(
            <div style={{background:C.goldSurface,borderRadius:12,padding:"10px 14px",marginBottom:16,fontSize:12,fontWeight:700,color:C.charcoal,display:"flex",alignItems:"center",gap:8}}>
              <Ic n="building" size={14} color={C.gold}/> {preselectedApt.name}
            </div>
          )}
          {emptyBeds.length===0
            ?<div style={{textAlign:"center",padding:"40px 0",color:C.slate}}>
              <Ic n="bed" size={36} color={C.divider}/>
              <div style={{marginTop:10,fontSize:14}}>مفيش سراير فاضية</div>
            </div>
            :emptyBeds.map(bed=>(
              <div key={bed.id} onClick={()=>{setSelBedId(bed.id);setSelRoomId(bed.roomId);if(bed.price)setRent(String(bed.price));setStep(preselectedApt?2:3);}}
                style={{background:C.white,border:`1.5px solid ${selBedId===bed.id?C.blue:C.divider}`,borderRadius:16,padding:16,marginBottom:10,cursor:"pointer",display:"flex",alignItems:"center",gap:12}}>
                <div style={{width:44,height:44,borderRadius:12,background:C.blueSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  <Ic n="bed" size={20} color={C.blue}/>
                </div>
                <div style={{flex:1}}>
                  <div style={{fontSize:14,fontWeight:800,color:C.charcoal}}>{bed.roomName} · {bed.label}</div>
                  {bed.price>0&&<div style={{fontSize:12,color:C.gold,fontWeight:700,marginTop:2}}>EGP {bed.price.toLocaleString()}/شهر</div>}
                </div>
                <Ic n="chevronRight" size={18} color={C.slate}/>
              </div>
            ))
          }
          {!preselectedApt&&(
            <Btn label="← غيّر الشقة" fill={false} color={C.slate} small onClick={()=>setStep(1)} style={{width:"100%",marginTop:4}}/>
          )}
        </div>
      )}

      {/* STEP 3: Housing details */}
      {((!preselectedApt&&step===3)||(preselectedApt&&step===2))&&(
        <div>
          <div style={{background:C.goldSurface,border:`1px solid ${C.gold}33`,borderRadius:14,padding:"12px 16px",marginBottom:20}}>
            <div style={{fontSize:13,fontWeight:800,color:C.charcoal,marginBottom:6}}>ملخص الحجز</div>
            <div style={{display:"flex",alignItems:"center",gap:6,marginBottom:4}}>
              <Ic n="person" size={13} color={C.gold}/><span style={{fontSize:12,color:C.charcoal,fontWeight:600}}>{name}</span>
            </div>
            <div style={{display:"flex",alignItems:"center",gap:6,marginBottom:4}}>
              <Ic n="phone" size={13} color={C.slate}/><span style={{fontSize:12,color:C.slate}}>{phone}</span>
            </div>
            <div style={{display:"flex",alignItems:"center",gap:6}}>
              <Ic n="bed" size={13} color={C.blue}/><span style={{fontSize:12,color:C.slate}}>{selApt?.name} · {selBed?.roomName} · {selBed?.label}</span>
            </div>
          </div>
          <Field label="الإيجار الشهري (EGP)" placeholder="1200" value={rent} onChange={setRent} type="number" prefix="EGP"/>
          <Field label="تاريخ بدء الإقامة" value={since} onChange={setSince} select options={MONTHS.map(v=>({v,l:v}))}/>
        </div>
      )}
    </Sheet>
  );
}

// ─── EDIT TENANT MODAL ────────────────────────────────────────────────────────
function EditTenantModal({bed,aptName,roomName,onClose,onSave}){
  const t=bed.tenant;
  const [name,setName]=useState(t.name);
  const [phone,setPhone]=useState(t.phone);
  const [rent,setRent]=useState(String(t.rent));
  const [since,setSince]=useState(t.since);
  const [paid,setPaid]=useState(t.paid);
  return(
    <Sheet title="تعديل بيانات الساكن" onClose={onClose}
      footer={<Btn label="حفظ التعديلات" onClick={()=>onSave({name,phone,rent:parseInt(rent),since,paid})} style={{width:"100%"}}/>}>
      <div style={{background:C.goldSurface,borderRadius:12,padding:"10px 14px",marginBottom:16,fontSize:12,color:C.charcoal,display:"flex",alignItems:"center",gap:6}}>
        <Ic n="location" size={13} color={C.gold}/> <strong>{aptName}</strong> · {roomName} · <strong>{bed.label}</strong>
      </div>
      <Field label="الاسم الكامل" value={name} onChange={setName}/>
      <Field label="رقم التليفون" value={phone} onChange={setPhone} type="tel"/>
      <Field label="الإيجار الشهري (EGP)" value={rent} onChange={setRent} type="number" prefix="EGP"/>
      <Field label="ساكن من" value={since} onChange={setSince} select options={MONTHS.map(v=>({v,l:v}))}/>
      <div style={{marginBottom:14}}>
        <div style={{fontSize:12,fontWeight:600,color:C.charcoal,marginBottom:8}}>حالة الإيجار</div>
        <div style={{display:"flex",gap:10}}>
          {[[true,"مدفوع",C.green,C.greenSurface],[false,"متأخر",C.red,C.redSurface]].map(([val,lbl,col,bg])=>(
            <div key={lbl} onClick={()=>setPaid(val)} style={{flex:1,padding:"12px 0",borderRadius:12,textAlign:"center",cursor:"pointer",background:paid===val?bg:C.white,border:`1.5px solid ${paid===val?col:C.divider}`,fontSize:13,fontWeight:paid===val?800:500,color:paid===val?col:C.slate}}>
              {paid===val&&val&&<Ic n="check" size={14} color={C.green}/>} {lbl}
            </div>
          ))}
        </div>
      </div>
    </Sheet>
  );
}

// ─── TENANT DETAIL SHEET ──────────────────────────────────────────────────────
function TenantDetailSheet({bed,aptName,roomName,onClose,onEdit,onRemove,onCallReminder}){
  const t=bed.tenant;
  return(
    <Sheet title="بيانات الساكن" onClose={onClose}
      footer={
        <div style={{display:"flex",flexDirection:"column",gap:10}}>
          <div style={{display:"flex",gap:10}}>
            <Btn label="واتساب" color="#25D366" small onClick={onClose} style={{flex:1}}/>
            <Btn label="تذكير بالإيجار" color={C.gold} small onClick={onCallReminder} style={{flex:1}}/>
          </div>
          <div style={{display:"flex",gap:10}}>
            <Btn label="تعديل" color={C.blue} small fill={false} onClick={onEdit} style={{flex:1}}/>
            <Btn label="إخلاء السرير" color={C.red} small fill={false} onClick={onRemove} style={{flex:1}}/>
          </div>
        </div>
      }>
      <div style={{textAlign:"center",marginBottom:22}}>
        <div style={{width:68,height:68,borderRadius:99,background:C.goldSurface,margin:"0 auto 12px",display:"flex",alignItems:"center",justifyContent:"center"}}>
          <Ic n="person" size={32} color={C.gold}/>
        </div>
        <div style={{fontSize:22,fontWeight:900,color:C.charcoal}}>{t.name}</div>
        <div style={{fontSize:12,color:C.slate,marginTop:3}}>{aptName} · {roomName} · {bed.label}</div>
      </div>
      {[
        [<Ic n="phone" size={15} color={C.slate}/>,"التليفون",t.phone],
        [<Ic n="calendar" size={15} color={C.slate}/>,"ساكن من",t.since],
        [<Ic n="money" size={15} color={C.slate}/>,"الإيجار",`EGP ${t.rent.toLocaleString()}/شهر`],
      ].map(([icon,label,val])=>(
        <div key={label} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"13px 0",borderBottom:`1px solid ${C.divider}`}}>
          <div style={{display:"flex",alignItems:"center",gap:8,color:C.slate,fontSize:13}}>{icon}{label}</div>
          <span style={{fontSize:13,fontWeight:700,color:C.charcoal}}>{val}</span>
        </div>
      ))}
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"13px 0",marginBottom:4}}>
        <div style={{display:"flex",alignItems:"center",gap:8,color:C.slate,fontSize:13}}><Ic n="wallet" size={15} color={C.slate}/>حالة الإيجار</div>
        <Pill label={t.paid?"مدفوع":"متأخر"} color={t.paid?C.green:C.red} bg={t.paid?C.greenSurface:C.redSurface} size={12}/>
      </div>
    </Sheet>
  );
}

// ─── EDIT APARTMENT MODAL — FULL EDIT ─────────────────────────────────────────
function EditAptModal({apt,onClose,onSave}){
  const [activeTab,setActiveTab]=useState("info");
  const [name,setName]=useState(apt.name);
  const [area,setArea]=useState(apt.area);
  const [address,setAddress]=useState(apt.address);
  const [floor,setFloor]=useState(String(apt.floor));
  const [rooms,setRooms]=useState(apt.rooms.map(r=>({
    id:r.id, name:r.name, isNew:false, deleted:false,
    beds:r.beds.map(b=>({id:b.id,label:b.label,price:String(b.price||""),isNew:false,deleted:false})),
  })));

  const addRoom=()=>{
    const rid=`r_new_${Date.now()}`;
    setRooms(p=>[...p,{id:rid,name:`غرفة ${p.filter(r=>!r.deleted).length+1}`,isNew:true,deleted:false,
      beds:[{id:`b_new_${Date.now()}`,label:"سرير A",price:"",isNew:true,deleted:false}]}]);
  };
  const delRoom=id=>setRooms(p=>p.map(r=>r.id===id?{...r,deleted:true}:r));
  const updRoom=(id,f,v)=>setRooms(p=>p.map(r=>r.id===id?{...r,[f]:v}:r));

  const addBed=roomId=>{
    const existingBeds=rooms.find(r=>r.id===roomId).beds.filter(b=>!b.deleted);
    const labels=["A","B","C","D","E"];
    const label=`سرير ${labels[existingBeds.length]||existingBeds.length+1}`;
    setRooms(p=>p.map(r=>r.id!==roomId?r:{...r,beds:[...r.beds,{id:`b_new_${Date.now()}`,label,price:"",isNew:true,deleted:false}]}));
  };
  const delBed=(roomId,bedId)=>setRooms(p=>p.map(r=>r.id!==roomId?r:{...r,beds:r.beds.map(b=>b.id===bedId?{...b,deleted:true}:b)}));
  const updBed=(roomId,bedId,f,v)=>setRooms(p=>p.map(r=>r.id!==roomId?r:{...r,beds:r.beds.map(b=>b.id===bedId?{...b,[f]:v}:b)}));

  const handleSave=()=>{
    const updatedApt={
      name,area,address,floor:parseInt(floor)||1,
      rooms:rooms.filter(r=>!r.deleted).map(r=>({
        ...apt.rooms.find(x=>x.id===r.id)||{},
        id:r.id,name:r.name,
        beds:r.beds.filter(b=>!b.deleted).map(b=>{
          const origBed=apt.rooms.flatMap(room=>room.beds).find(x=>x.id===b.id)||{};
          return{...origBed,id:b.id,label:b.label,price:parseInt(b.price)||0};
        })
      }))
    };
    onSave(updatedApt);
  };

  const visRooms=rooms.filter(r=>!r.deleted);
  const totalRev=visRooms.reduce((a,r)=>a+r.beds.filter(b=>!b.deleted).reduce((s,b)=>s+(parseInt(b.price)||0),0),0);

  return(
    <Sheet title="تعديل الشقة" onClose={onClose}
      footer={<Btn label="حفظ كل التعديلات" onClick={handleSave} style={{width:"100%"}}/>}>
      {/* Tabs */}
      <div style={{display:"flex",gap:0,borderBottom:`2px solid ${C.divider}`,marginBottom:18}}>
        {[["info","بيانات الشقة"],["rooms","الغرف والسراير"]].map(([t,l])=>(
          <button key={t} onClick={()=>setActiveTab(t)} style={{flex:1,padding:"10px 0",background:"none",border:"none",borderBottom:`2.5px solid ${activeTab===t?C.gold:"transparent"}`,fontFamily:font,fontSize:13,fontWeight:activeTab===t?800:500,color:activeTab===t?C.charcoal:C.slate,cursor:"pointer",marginBottom:-2}}>
            {l}
          </button>
        ))}
      </div>

      {activeTab==="info"&&(
        <>
          <Field label="اسم الشقة" value={name} onChange={setName}/>
          <Field label="المنطقة" value={area} onChange={setArea} select options={AREAS.map(v=>({v,l:v}))}/>
          <Field label="العنوان التفصيلي" value={address} onChange={setAddress}/>
          <Field label="الدور" value={floor} onChange={setFloor} type="number"/>
        </>
      )}

      {activeTab==="rooms"&&(
        <>
          {totalRev>0&&(
            <div style={{background:C.greenSurface,border:`1px solid ${C.green}33`,borderRadius:12,padding:"10px 14px",marginBottom:16,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
              <div style={{display:"flex",alignItems:"center",gap:6,fontSize:12,color:C.green,fontWeight:700}}>
                <Ic n="money" size={14} color={C.green}/> إيراد شهري متوقع
              </div>
              <span style={{fontSize:14,fontWeight:900,color:C.green}}>EGP {totalRev.toLocaleString()}</span>
            </div>
          )}

          {visRooms.map(r=>(
            <div key={r.id} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:16,padding:14,marginBottom:12}}>
              {/* Room name + delete */}
              <div style={{display:"flex",gap:10,alignItems:"center",marginBottom:12}}>
                <div style={{width:36,height:36,borderRadius:10,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  <Ic n="door" size={18} color={C.gold}/>
                </div>
                <input value={r.name} onChange={e=>updRoom(r.id,"name",e.target.value)}
                  style={{flex:1,padding:"9px 12px",borderRadius:10,border:`1.5px solid ${C.divider}`,fontFamily:font,fontSize:13,fontWeight:700,outline:"none"}}/>
                {visRooms.length>1&&(
                  <button onClick={()=>delRoom(r.id)} style={{width:34,height:34,borderRadius:9,background:C.redSurface,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                    <Ic n="trash" size={15} color={C.red}/>
                  </button>
                )}
              </div>

              {/* Beds */}
              <div style={{fontSize:11,fontWeight:600,color:C.slate,marginBottom:8}}>السراير</div>
              {r.beds.filter(b=>!b.deleted).map(b=>(
                <div key={b.id} style={{display:"flex",gap:8,alignItems:"center",marginBottom:8,background:"#F8F9FF",borderRadius:10,padding:"8px 10px"}}>
                  <div style={{width:28,height:28,borderRadius:8,background:C.blueSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                    <Ic n="bed" size={14} color={C.blue}/>
                  </div>
                  <input value={b.label} onChange={e=>updBed(r.id,b.id,"label",e.target.value)}
                    style={{width:70,padding:"7px 9px",borderRadius:8,border:`1px solid ${C.divider}`,fontFamily:font,fontSize:12,outline:"none"}}/>
                  <div style={{flex:1,position:"relative"}}>
                    <input value={b.price} onChange={e=>updBed(r.id,b.id,"price",e.target.value)} placeholder="السعر" type="number"
                      style={{width:"100%",padding:"7px 10px",paddingLeft:38,borderRadius:8,border:`1.5px solid ${b.price?C.gold:C.divider}`,fontFamily:font,fontSize:12,fontWeight:700,outline:"none",boxSizing:"border-box",background:b.price?"#FFFBF3":C.white}}/>
                    <span style={{position:"absolute",left:10,top:"50%",transform:"translateY(-50%)",fontSize:10,color:C.slate,fontWeight:700}}>EGP</span>
                  </div>
                  {r.beds.filter(b=>!b.deleted).length>1&&(
                    <button onClick={()=>delBed(r.id,b.id)} style={{width:28,height:28,borderRadius:8,background:C.redSurface,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                      <Ic n="close" size={12} color={C.red}/>
                    </button>
                  )}
                </div>
              ))}

              <button onClick={()=>addBed(r.id)} style={{width:"100%",padding:"8px 0",borderRadius:9,border:`1.5px dashed ${C.blue}66`,background:"none",color:C.blue,fontFamily:font,fontSize:12,fontWeight:700,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",gap:6}}>
                <Ic n="plus" size={13} color={C.blue}/> إضافة سرير
              </button>
            </div>
          ))}

          <button onClick={addRoom} style={{width:"100%",padding:"12px 0",borderRadius:14,border:`1.5px dashed ${C.gold}66`,background:"none",color:C.gold,fontFamily:font,fontSize:13,fontWeight:700,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",gap:8}}>
            <Ic n="plus" size={15} color={C.gold}/> إضافة غرفة جديدة
          </button>
        </>
      )}
    </Sheet>
  );
}

// ─── ADD APARTMENT MODAL ──────────────────────────────────────────────────────
function AddAptModal({onClose,onSave}){
  const [step,setStep]=useState(0);
  const [apt,setApt]=useState({name:"",area:"الحي السادس",address:"",floor:"١"});
  const [rooms,setRooms]=useState([{id:"nr1",name:"غرفة ١",beds:2,price:""}]);

  const addRoom=()=>setRooms(r=>[...r,{id:`nr${Date.now()}`,name:`غرفة ${r.length+1}`,beds:2,price:""}]);
  const upd=(id,f,v)=>setRooms(r=>r.map(rm=>rm.id===id?{...rm,[f]:v}:rm));
  const del=id=>setRooms(r=>r.filter(rm=>rm.id!==id));
  const totalBeds=rooms.reduce((a,r)=>a+r.beds,0);
  const totalRev=rooms.reduce((a,r)=>a+(parseInt(r.price)||0)*r.beds,0);

  const save=()=>onSave({
    id:`a${Date.now()}`,name:apt.name||`شقة ${apt.area}`,area:apt.area,address:apt.address,floor:parseInt(apt.floor)||1,
    rooms:rooms.map((r,ri)=>({
      id:`r${Date.now()}_${ri}`,name:r.name,
      beds:Array.from({length:r.beds},(_,i)=>({
        id:`b${Date.now()}_${ri}_${i}`,
        label:r.beds===1?"سرير":`سرير ${["A","B","C","D"][i]}`,
        price:parseInt(r.price)||0,tenant:null,
      }))
    }))
  });

  const footer=(
    <>
      {step===0&&<Btn label="التالي ←" onClick={()=>setStep(1)} disabled={!apt.name&&!apt.area} style={{width:"100%"}}/>}
      {step===1&&(
        <div style={{display:"flex",gap:10}}>
          <Btn label="← سابق" fill={false} color={C.slate} onClick={()=>setStep(0)} style={{flex:1}}/>
          <Btn label="مراجعة" onClick={()=>setStep(2)} style={{flex:2}}/>
        </div>
      )}
      {step===2&&(
        <div style={{display:"flex",gap:10}}>
          <Btn label="← عدّل" fill={false} color={C.slate} onClick={()=>setStep(1)} style={{flex:1}}/>
          <Btn label="حفظ الشقة" onClick={save} style={{flex:2}}/>
        </div>
      )}
    </>
  );

  return(
    <Sheet title={["بيانات الشقة","الغرف والسراير","مراجعة"][step]} onClose={onClose} footer={footer}>
      <Steps current={step} total={3}/>

      {step===0&&(
        <>
          <Field label="اسم الشقة / الكمبوند" placeholder="شقة الحديقة - مبنى ٣" value={apt.name} onChange={v=>setApt(a=>({...a,name:v}))}/>
          <Field label="المنطقة" value={apt.area} onChange={v=>setApt(a=>({...a,area:v}))} select options={AREAS.map(v=>({v,l:v}))}/>
          <Field label="العنوان التفصيلي" placeholder="شارع، مبنى، شقة" value={apt.address} onChange={v=>setApt(a=>({...a,address:v}))}/>
          <Field label="الدور" value={apt.floor} onChange={v=>setApt(a=>({...a,floor:v}))} type="number"/>
        </>
      )}

      {step===1&&(
        <>
          {rooms.map(r=>(
            <div key={r.id} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:16,padding:14,marginBottom:12}}>
              <div style={{display:"flex",gap:10,marginBottom:12,alignItems:"center"}}>
                <div style={{width:36,height:36,borderRadius:10,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  <Ic n="door" size={18} color={C.gold}/>
                </div>
                <input value={r.name} onChange={e=>upd(r.id,"name",e.target.value)}
                  style={{flex:1,padding:"9px 12px",borderRadius:10,border:`1px solid ${C.divider}`,fontFamily:font,fontSize:13,fontWeight:700,outline:"none"}}/>
                {rooms.length>1&&<button onClick={()=>del(r.id)} style={{width:32,height:32,borderRadius:9,background:C.redSurface,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}><Ic n="trash" size={14} color={C.red}/></button>}
              </div>
              <div style={{fontSize:11,fontWeight:600,color:C.slate,marginBottom:8}}>عدد السراير</div>
              <div style={{display:"flex",gap:8,marginBottom:12}}>
                {[1,2,3,4].map(n=>(
                  <div key={n} onClick={()=>upd(r.id,"beds",n)} style={{flex:1,padding:"10px 0",borderRadius:10,textAlign:"center",cursor:"pointer",background:r.beds===n?C.goldSurface:C.white,border:`1.5px solid ${r.beds===n?C.gold:C.divider}`,fontSize:12,fontWeight:r.beds===n?900:400,color:r.beds===n?C.charcoal:C.slate}}>
                    <div style={{display:"flex",justifyContent:"center",marginBottom:3}}><Ic n="bed" size={14} color={r.beds===n?C.gold:C.slate}/></div>
                    {n}
                  </div>
                ))}
              </div>
              <div style={{fontSize:11,fontWeight:600,color:C.slate,marginBottom:6}}>سعر السرير / شهر</div>
              <div style={{position:"relative"}}>
                <input value={r.price} onChange={e=>upd(r.id,"price",e.target.value)} placeholder="1200" type="number"
                  style={{width:"100%",padding:"10px 14px",paddingLeft:50,borderRadius:10,border:`1.5px solid ${r.price?C.gold:C.divider}`,fontFamily:font,fontSize:14,fontWeight:700,outline:"none",boxSizing:"border-box",background:r.price?"#FFFBF3":C.white}}/>
                <span style={{position:"absolute",left:12,top:"50%",transform:"translateY(-50%)",fontSize:11,fontWeight:700,color:C.slate}}>EGP</span>
              </div>
              {r.price&&<div style={{fontSize:11,color:C.green,fontWeight:600,marginTop:6,display:"flex",alignItems:"center",gap:4}}><Ic n="money" size={12} color={C.green}/> إيراد الغرفة: EGP {(parseInt(r.price)*r.beds).toLocaleString()}/شهر</div>}
            </div>
          ))}
          <button onClick={addRoom} style={{width:"100%",padding:"12px 0",borderRadius:14,border:`1.5px dashed ${C.gold}66`,background:"none",color:C.gold,fontFamily:font,fontSize:13,fontWeight:700,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",gap:8}}>
            <Ic n="plus" size={15} color={C.gold}/> إضافة غرفة
          </button>
          {totalRev>0&&<div style={{background:C.goldSurface,borderRadius:12,padding:"10px 14px",marginTop:12,fontSize:12,color:C.charcoal,display:"flex",justifyContent:"space-between"}}>
            <span>{rooms.length} غرف · {totalBeds} سرير</span>
            <strong style={{color:C.green}}>EGP {totalRev.toLocaleString()}/شهر</strong>
          </div>}
        </>
      )}

      {step===2&&(
        <>
          <div style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:16,padding:16,marginBottom:14}}>
            <div style={{fontSize:15,fontWeight:800,color:C.charcoal,marginBottom:10}}>🏢 {apt.name||"شقة جديدة"}</div>
            {[[<Ic n="location" size={13} color={C.slate}/>,apt.area],[<Ic n="building" size={13} color={C.slate}/>,`الدور ${apt.floor}`],[<Ic n="door" size={13} color={C.slate}/>,`${rooms.length} غرف`],[<Ic n="bed" size={13} color={C.slate}/>,`${totalBeds} سرير`]].map(([icon,v],i)=>(
              <div key={i} style={{fontSize:12,color:C.slate,marginBottom:5,display:"flex",alignItems:"center",gap:6}}>{icon}{v}</div>
            ))}
          </div>
          {rooms.map(r=>(
            <div key={r.id} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"10px 14px",background:C.white,border:`1px solid ${C.divider}`,borderRadius:12,marginBottom:8}}>
              <div style={{display:"flex",alignItems:"center",gap:8,fontSize:13,fontWeight:700,color:C.charcoal}}>
                <Ic n="door" size={15} color={C.gold}/>{r.name} · {r.beds} سرير
              </div>
              {r.price&&<span style={{fontSize:12,fontWeight:800,color:C.gold}}>EGP {parseInt(r.price).toLocaleString()}/سرير</span>}
            </div>
          ))}
          {totalRev>0&&(
            <div style={{background:C.greenSurface,border:`1px solid ${C.green}33`,borderRadius:12,padding:"12px 16px",display:"flex",justifyContent:"space-between",marginTop:8}}>
              <div style={{display:"flex",alignItems:"center",gap:6,fontSize:13,color:C.green,fontWeight:700}}><Ic n="money" size={14} color={C.green}/>إيراد شهري متوقع</div>
              <span style={{fontSize:15,fontWeight:900,color:C.green}}>EGP {totalRev.toLocaleString()}</span>
            </div>
          )}
        </>
      )}
    </Sheet>
  );
}

// ─── BED CARD ─────────────────────────────────────────────────────────────────
const BedCard=({bed,onAdd,onView})=>{
  const occ=!!bed.tenant;
  return(
    <div style={{background:occ?C.white:"#F8FAFF",border:`1.5px ${occ?"solid":"dashed"} ${occ?C.divider:C.blue+"44"}`,borderRadius:13,padding:"12px 14px",display:"flex",alignItems:"center",gap:10}}>
      <div style={{width:36,height:36,borderRadius:11,flexShrink:0,background:occ?C.goldSurface:C.blueSurface,display:"flex",alignItems:"center",justifyContent:"center"}}>
        <Ic n={occ?"person":"bed"} size={18} color={occ?C.gold:C.blue}/>
      </div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontSize:11,color:C.slate,fontWeight:600,marginBottom:2}}>{bed.label}</div>
        {occ?(
          <>
            <div style={{fontSize:13,fontWeight:800,color:C.charcoal,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{bed.tenant.name}</div>
            <div style={{display:"flex",gap:6,alignItems:"center",marginTop:2}}>
              <span style={{fontSize:11,color:C.green,fontWeight:700}}>EGP {bed.tenant.rent.toLocaleString()}</span>
              <Pill label={bed.tenant.paid?"مدفوع":"متأخر"} color={bed.tenant.paid?C.green:C.red} bg={bed.tenant.paid?C.greenSurface:C.redSurface}/>
            </div>
          </>
        ):(
          <div style={{fontSize:12,color:C.blue,fontWeight:600}}>فاضي{bed.price>0?` · EGP ${bed.price.toLocaleString()}`:""}</div>
        )}
      </div>
      {occ
        ?<button onClick={onView} style={{width:32,height:32,borderRadius:9,background:C.goldSurface,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center"}}><Ic n="eye" size={15} color={C.gold}/></button>
        :<button onClick={onAdd} style={{width:32,height:32,borderRadius:9,background:C.blueSurface,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center"}}><Ic n="plus" size={15} color={C.blue}/></button>
      }
    </div>
  );
};

const RoomCard=({room,onAdd,onView})=>{
  const [open,setOpen]=useState(true);
  const occ=room.beds.filter(b=>b.tenant).length;
  const total=room.beds.length;
  return(
    <div style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:17,marginBottom:10,overflow:"hidden"}}>
      <div onClick={()=>setOpen(o=>!o)} style={{padding:"14px 16px",display:"flex",alignItems:"center",gap:12,cursor:"pointer"}}>
        <div style={{width:38,height:38,borderRadius:11,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
          <Ic n="door" size={20} color={C.gold}/>
        </div>
        <div style={{flex:1}}>
          <div style={{fontSize:14,fontWeight:800,color:C.charcoal}}>{room.name}</div>
          <div style={{display:"flex",gap:8,alignItems:"center",marginTop:4}}>
            <span style={{fontSize:11,color:C.slate}}>{occ}/{total} محجوز</span>
            <div style={{width:50,height:4,background:C.divider,borderRadius:4}}>
              <div style={{width:`${(occ/total)*100}%`,height:"100%",background:occ===total?C.green:C.gold,borderRadius:4}}/>
            </div>
          </div>
        </div>
        <div style={{transform:open?"rotate(180deg)":"none",transition:"transform 0.2s"}}>
          <Ic n="chevronDown" size={18} color={C.slate}/>
        </div>
      </div>
      {open&&(
        <div style={{padding:"0 14px 14px",display:"flex",flexDirection:"column",gap:8}}>
          {room.beds.map(bed=>(
            <BedCard key={bed.id} bed={bed} onAdd={()=>onAdd(room,bed)} onView={()=>onView(room,bed)}/>
          ))}
        </div>
      )}
    </div>
  );
};

// ─── APARTMENTS SCREEN ────────────────────────────────────────────────────────
function ApartmentsScreen({apts,setApts,setModal}){
  const [selId,setSelId]=useState(null);
  const [editApt,setEditApt]=useState(null);
  const [addTenantApt,setAddTenantApt]=useState(null);
  const selApt=apts.find(a=>a.id===selId);

  const saveEditApt=(updated)=>{
    setApts(p=>p.map(a=>a.id===editApt.id?{...a,...updated}:a));
    setEditApt(null);
  };
  const saveNewTenant=data=>{
    setApts(p=>p.map(a=>a.id!==data.aptId?a:{...a,rooms:a.rooms.map(r=>r.id!==data.roomId?r:{...r,beds:r.beds.map(b=>b.id!==data.bedId?b:{...b,tenant:{name:data.name,phone:data.phone,rent:data.rent,since:data.since,paid:true}})})}));
    setAddTenantApt(null);
  };

  const totalBeds=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.length,0),0);
  const occBeds=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.filter(bd=>bd.tenant).length,0),0);

  if(selApt){
    const aptBeds=selApt.rooms.reduce((a,r)=>a+r.beds.length,0);
    const aptOcc=selApt.rooms.reduce((a,r)=>a+r.beds.filter(b=>b.tenant).length,0);
    const aptRev=selApt.rooms.reduce((a,r)=>a+r.beds.filter(b=>b.tenant).reduce((c,b)=>c+b.tenant.rent,0),0);
    return(
      <div style={{height:"100%",display:"flex",flexDirection:"column",background:C.cream,direction:"rtl",fontFamily:font}}>
        <div style={{padding:"16px 22px 0",flexShrink:0}}>
          <div style={{display:"flex",alignItems:"center",gap:10,marginBottom:14}}>
            <BackBtn onClick={()=>setSelId(null)}/>
            <div style={{flex:1}}>
              <div style={{fontSize:16,fontWeight:800,color:C.charcoal}}>{selApt.name}</div>
              <div style={{fontSize:11,color:C.slate,marginTop:2,display:"flex",alignItems:"center",gap:4}}><Ic n="location" size={11} color={C.slate}/>{selApt.area} · الدور {selApt.floor}</div>
            </div>
            <button onClick={()=>setEditApt(selApt)} style={{background:C.goldSurface,border:`1px solid ${C.gold}44`,borderRadius:11,padding:"7px 13px",fontFamily:font,fontSize:12,fontWeight:700,color:C.gold,cursor:"pointer",display:"flex",alignItems:"center",gap:5}}>
              <Ic n="edit" size={13} color={C.gold}/>تعديل
            </button>
          </div>
          <div style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:16,padding:14,marginBottom:14}}>
            <div style={{display:"flex",justifyContent:"space-between",marginBottom:8}}>
              <span style={{fontSize:12,color:C.slate}}>نسبة الإشغال</span>
              <span style={{fontSize:13,fontWeight:800}}>{Math.round((aptOcc/aptBeds)*100)}%</span>
            </div>
            <div style={{height:8,background:C.divider,borderRadius:8,marginBottom:8}}>
              <div style={{width:`${(aptOcc/aptBeds)*100}%`,height:"100%",background:aptOcc===aptBeds?C.green:C.gold,borderRadius:8}}/>
            </div>
            <div style={{display:"flex",justifyContent:"space-between"}}>
              <span style={{fontSize:11,color:C.green,display:"flex",alignItems:"center",gap:4}}><Ic n="check" size={11} color={C.green}/>{aptOcc} ساكن</span>
              <span style={{fontSize:12,fontWeight:800,color:C.gold}}>EGP {aptRev.toLocaleString()}/شهر</span>
              <span style={{fontSize:11,color:C.blue,display:"flex",alignItems:"center",gap:4}}><Ic n="bed" size={11} color={C.blue}/>{aptBeds-aptOcc} فاضي</span>
            </div>
          </div>
        </div>
        <div style={{flex:1,overflowY:"auto",padding:"0 22px 16px"}}>
          {selApt.rooms.map(room=>(
            <RoomCard key={room.id} room={room}
              onAdd={(room,bed)=>setModal({type:"addTenant",apt:selApt,room,bed})}
              onView={(room,bed)=>setModal({type:"viewTenant",apt:selApt,room,bed})}
            />
          ))}
        </div>
        <div style={{padding:"12px 22px 20px",flexShrink:0,background:C.cream,borderTop:`1px solid ${C.divider}`}}>
          <Btn label="إضافة ساكن لهذه الشقة" onClick={()=>setAddTenantApt(selApt)} style={{width:"100%"}}/>
        </div>
        {editApt&&<EditAptModal apt={editApt} onClose={()=>setEditApt(null)} onSave={saveEditApt}/>}
        {addTenantApt&&<AddTenantWithPickerModal apts={apts} preselectedApt={addTenantApt} onClose={()=>setAddTenantApt(null)} onSave={saveNewTenant}/>}
      </div>
    );
  }

  return(
    <div style={{height:"100%",display:"flex",flexDirection:"column",background:C.cream,direction:"rtl",fontFamily:font}}>
      <div style={{padding:"22px 22px 0",flexShrink:0}}>
        <div style={{fontSize:20,fontWeight:800,color:C.charcoal,marginBottom:16}}>شققي</div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:10,marginBottom:18}}>
          {[[apts.length,"شقة","building",C.gold],[occBeds,"ساكن","person",C.green],[totalBeds-occBeds,"فاضي","bed",C.blue]].map(([v,l,icon,col])=>(
            <div key={l} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:16,padding:"14px 10px",textAlign:"center"}}>
              <div style={{display:"flex",justifyContent:"center",marginBottom:6}}><Ic n={icon} size={20} color={col}/></div>
              <div style={{fontSize:22,fontWeight:900,color:col}}>{v}</div>
              <div style={{fontSize:10,color:C.slate,marginTop:2}}>{l}</div>
            </div>
          ))}
        </div>
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"0 22px 110px"}}>
        {apts.map(apt=>{
          const beds=apt.rooms.reduce((a,r)=>a+r.beds.length,0);
          const occ=apt.rooms.reduce((a,r)=>a+r.beds.filter(b=>b.tenant).length,0);
          return(
            <div key={apt.id} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:18,padding:16,marginBottom:12}}>
              <div style={{display:"flex",gap:12,alignItems:"flex-start"}}>
                <div onClick={()=>setSelId(apt.id)} style={{width:50,height:50,background:C.goldSurface,borderRadius:15,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,cursor:"pointer"}}>
                  <Ic n="building" size={26} color={C.gold}/>
                </div>
                <div style={{flex:1,cursor:"pointer"}} onClick={()=>setSelId(apt.id)}>
                  <div style={{fontSize:14,fontWeight:800,color:C.charcoal}}>{apt.name}</div>
                  <div style={{fontSize:11,color:C.slate,marginTop:2,display:"flex",alignItems:"center",gap:4}}><Ic n="location" size={11} color={C.slate}/>{apt.area} · {apt.rooms.length} غرف · {beds} سرير</div>
                  <div style={{marginTop:8,height:5,background:C.divider,borderRadius:5}}>
                    <div style={{width:`${(occ/beds)*100}%`,height:"100%",background:occ===beds?C.green:C.gold,borderRadius:5}}/>
                  </div>
                  <div style={{display:"flex",justifyContent:"space-between",marginTop:5}}>
                    <span style={{fontSize:11,color:C.green,display:"flex",alignItems:"center",gap:3}}><Ic n="check" size={11} color={C.green}/>{occ} ساكن</span>
                    <span style={{fontSize:11,color:C.blue,display:"flex",alignItems:"center",gap:3}}><Ic n="bed" size={11} color={C.blue}/>{beds-occ} فاضي</span>
                  </div>
                </div>
                <button onClick={()=>setEditApt(apt)} style={{background:"none",border:"none",cursor:"pointer",padding:4}}>
                  <Ic n="edit" size={17} color={C.slate}/>
                </button>
              </div>
            </div>
          );
        })}
      </div>
      {editApt&&<EditAptModal apt={editApt} onClose={()=>setEditApt(null)} onSave={data=>{setApts(p=>p.map(a=>a.id===editApt.id?{...a,...data}:a));setEditApt(null);}}/>}
    </div>
  );
}

// ─── CLIENTS SCREEN ───────────────────────────────────────────────────────────
function ClientsScreen({apts,setApts,setShowAddTenant}){
  const unpaid=apts.flatMap(apt=>apt.rooms.flatMap(r=>r.beds.filter(b=>b.tenant&&!b.tenant.paid).map(b=>({...b.tenant,aptName:apt.name,roomName:r.name,bedLabel:b.label,bedId:b.id,roomId:r.id,aptId:apt.id}))));
  const allTenants=apts.flatMap(apt=>apt.rooms.flatMap(r=>r.beds.filter(b=>b.tenant).map(b=>({...b.tenant,aptName:apt.name,roomName:r.name,bedLabel:b.label,bedId:b.id,roomId:r.id,aptId:apt.id}))));
  const markPaid=(aptId,roomId,bedId)=>setApts(p=>p.map(a=>a.id!==aptId?a:{...a,rooms:a.rooms.map(r=>r.id!==roomId?r:{...r,beds:r.beds.map(b=>b.id!==bedId?b:{...b,tenant:{...b.tenant,paid:true}})})}));
  return(
    <div style={{height:"100%",overflowY:"auto",background:C.cream,direction:"rtl",fontFamily:font,padding:"22px 22px 110px"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <div>
          <div style={{fontSize:20,fontWeight:800,color:C.charcoal}}>العملاء</div>
          <div style={{fontSize:12,color:C.slate,marginTop:2}}>{allTenants.length} ساكن نشط</div>
        </div>
        <Btn label="إضافة ساكن" small onClick={()=>setShowAddTenant(true)}/>
      </div>
      {unpaid.length>0&&(
        <>
          <div style={{fontSize:13,fontWeight:800,color:C.red,marginBottom:10,display:"flex",alignItems:"center",gap:6}}>
            <Ic n="warning" size={15} color={C.red}/>إيجارات متأخرة ({unpaid.length})
          </div>
          {unpaid.map(t=>(
            <div key={t.bedId} style={{background:C.redSurface,border:`1px solid ${C.red}33`,borderRadius:16,padding:16,marginBottom:10,display:"flex",alignItems:"center",gap:12}}>
              <div style={{width:42,height:42,borderRadius:99,background:"#FEE2E2",display:"flex",alignItems:"center",justifyContent:"center",fontWeight:900,fontSize:14,color:C.red,flexShrink:0}}>{t.name[0]}</div>
              <div style={{flex:1}}>
                <div style={{fontSize:14,fontWeight:800,color:C.charcoal}}>{t.name}</div>
                <div style={{fontSize:11,color:C.slate,marginTop:2}}>{t.aptName} · {t.roomName}</div>
                <div style={{fontSize:12,fontWeight:700,color:C.red,marginTop:2}}>EGP {t.rent.toLocaleString()} متأخر</div>
              </div>
              <div style={{display:"flex",flexDirection:"column",gap:7}}>
                <button style={{background:C.green,border:"none",borderRadius:9,padding:"7px 11px",cursor:"pointer",display:"flex",alignItems:"center",gap:5,color:C.white,fontWeight:700,fontSize:11,fontFamily:font}}>
                  <Ic n="phone" size={12} color={C.white}/>رن
                </button>
                <button onClick={()=>markPaid(t.aptId,t.roomId,t.bedId)} style={{background:C.charcoal,border:"none",borderRadius:9,padding:"7px 11px",cursor:"pointer",display:"flex",alignItems:"center",gap:5,color:C.white,fontWeight:700,fontSize:11,fontFamily:font}}>
                  <Ic n="check" size={12} color={C.white}/>مدفوع
                </button>
              </div>
            </div>
          ))}
          <div style={{height:1,background:C.divider,margin:"16px 0"}}/>
        </>
      )}
      <div style={{fontSize:13,fontWeight:800,color:C.charcoal,marginBottom:12}}>كل السكان</div>
      {allTenants.map(t=>(
        <div key={t.bedId} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:15,padding:14,marginBottom:8,display:"flex",alignItems:"center",gap:12}}>
          <div style={{width:42,height:42,borderRadius:99,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center",fontWeight:900,fontSize:15,color:C.gold,flexShrink:0}}>{t.name[0]}</div>
          <div style={{flex:1}}>
            <div style={{fontSize:13,fontWeight:800,color:C.charcoal}}>{t.name}</div>
            <div style={{fontSize:11,color:C.slate,marginTop:2,display:"flex",alignItems:"center",gap:4}}><Ic n="location" size={11} color={C.slate}/>{t.aptName} · {t.bedLabel}</div>
            <div style={{fontSize:12,fontWeight:700,color:C.gold,marginTop:2}}>EGP {t.rent.toLocaleString()}/شهر</div>
          </div>
          <Pill label={t.paid?"مدفوع":"متأخر"} color={t.paid?C.green:C.red} bg={t.paid?C.greenSurface:C.redSurface} size={11}/>
        </div>
      ))}
      {allTenants.length===0&&(
        <div style={{textAlign:"center",marginTop:50,color:C.slate}}>
          <Ic n="users" size={48} color={C.divider}/>
          <div style={{marginTop:12,fontSize:14}}>مفيش سكان لحد دلوقتي</div>
          <Btn label="إضافة أول ساكن" onClick={()=>setShowAddTenant(true)} style={{marginTop:16}}/>
        </div>
      )}
    </div>
  );
}

// ─── HOME SCREEN ──────────────────────────────────────────────────────────────
function HomeScreen({apts,setTab}){
  const totalBeds=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.length,0),0);
  const occBeds=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.filter(bd=>bd.tenant).length,0),0);
  const rev=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.filter(bd=>bd.tenant).reduce((c,bd)=>c+bd.tenant.rent,0),0),0);
  const unpaid=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.filter(bd=>bd.tenant&&!bd.tenant.paid).length,0),0);
  return(
    <div style={{height:"100%",overflowY:"auto",background:C.cream,direction:"rtl",fontFamily:font}}>
      <div style={{background:C.charcoal,borderRadius:"0 0 30px 30px",padding:"26px 22px 28px"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
          <div>
            <div style={{fontSize:20,fontWeight:800,color:C.white}}>أهلاً، محمود! 👋</div>
            <div style={{fontSize:12,color:"#ffffff55",marginTop:2}}>أكتوبر - المحور</div>
          </div>
          <div style={{position:"relative"}}>
            <div style={{width:46,height:46,borderRadius:99,background:`${C.gold}33`,display:"flex",alignItems:"center",justifyContent:"center"}}>
              <span style={{fontSize:20,fontWeight:900,color:C.goldLight}}>م</span>
            </div>
            {unpaid>0&&<div style={{position:"absolute",top:-2,right:-2,width:18,height:18,background:C.red,borderRadius:99,display:"flex",alignItems:"center",justifyContent:"center",fontSize:9,fontWeight:800,color:C.white}}>{unpaid}</div>}
          </div>
        </div>
        <div style={{marginTop:18,background:C.gold,borderRadius:20,padding:"18px 20px"}}>
          <div style={{fontSize:11,color:"#ffffff99"}}>الإيرادات الشهرية</div>
          <div style={{fontSize:34,fontWeight:900,color:C.white,marginTop:2}}>EGP {rev.toLocaleString()}</div>
          <div style={{borderTop:"1px solid #ffffff33",margin:"14px 0"}}/>
          <div style={{display:"flex",justifyContent:"space-around"}}>
            {[[apts.length,"شقة","building"],[occBeds,"ساكن","person"],[totalBeds-occBeds,"فاضي","bed"]].map(([v,l,icon])=>(
              <div key={l} style={{textAlign:"center"}}>
                <div style={{display:"flex",justifyContent:"center",marginBottom:4,opacity:0.7}}><Ic n={icon} size={14} color={C.white}/></div>
                <div style={{fontSize:20,fontWeight:900,color:C.white}}>{v}</div>
                <div style={{fontSize:10,color:"#ffffff88"}}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <div style={{padding:"20px 22px 110px"}}>
        <div style={{height:10,background:C.divider,borderRadius:10,marginBottom:6}}>
          <div style={{width:`${Math.round((occBeds/Math.max(totalBeds,1))*100)}%`,height:"100%",background:C.gold,borderRadius:10}}/>
        </div>
        <div style={{display:"flex",justifyContent:"space-between",marginBottom:22}}>
          <span style={{fontSize:12,color:C.slate}}>نسبة الإشغال الكلية</span>
          <span style={{fontSize:12,fontWeight:800,color:C.gold}}>{Math.round((occBeds/Math.max(totalBeds,1))*100)}%</span>
        </div>
        {unpaid>0&&(
          <div onClick={()=>setTab(3)} style={{background:C.redSurface,border:`1px solid ${C.red}44`,borderRadius:17,padding:16,marginBottom:22,display:"flex",alignItems:"center",gap:12,cursor:"pointer"}}>
            <div style={{width:42,height:42,borderRadius:12,background:"#FEE2E2",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
              <Ic n="warning" size={22} color={C.red}/>
            </div>
            <div style={{flex:1}}>
              <div style={{fontSize:14,fontWeight:800,color:C.charcoal}}>{unpaid} إيجار متأخر</div>
              <div style={{fontSize:12,color:C.slate}}>اضغط لتذكير العملاء</div>
            </div>
            <Ic n="chevronRight" size={18} color={C.red}/>
          </div>
        )}
        <div style={{fontSize:15,fontWeight:800,color:C.charcoal,marginBottom:12}}>شققك</div>
        {apts.map(apt=>{
          const beds=apt.rooms.reduce((a,r)=>a+r.beds.length,0);
          const occ=apt.rooms.reduce((a,r)=>a+r.beds.filter(b=>b.tenant).length,0);
          return(
            <div key={apt.id} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:15,padding:14,marginBottom:10,display:"flex",alignItems:"center",gap:12}}>
              <div style={{width:42,height:42,borderRadius:12,background:C.goldSurface,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                <Ic n="building" size={22} color={C.gold}/>
              </div>
              <div style={{flex:1}}>
                <div style={{fontSize:13,fontWeight:700,color:C.charcoal}}>{apt.name}</div>
                <div style={{display:"flex",gap:3,marginTop:7}}>
                  {apt.rooms.flatMap(r=>r.beds).map(b=>(
                    <div key={b.id} style={{flex:1,height:5,borderRadius:5,background:b.tenant?C.green:C.divider}}/>
                  ))}
                </div>
              </div>
              <div style={{textAlign:"left"}}>
                <div style={{fontSize:14,fontWeight:900,color:occ===beds?C.green:C.gold}}>{occ}/{beds}</div>
                <div style={{fontSize:10,color:C.slate}}>سرير</div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─── EARNINGS SCREEN ─────────────────────────────────────────────────────────
function EarningsScreen({apts}){
  const rev=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.filter(bd=>bd.tenant).reduce((c,bd)=>c+bd.tenant.rent,0),0),0);
  return(
    <div style={{height:"100%",overflowY:"auto",background:C.cream,direction:"rtl",fontFamily:font,padding:"22px 22px 110px"}}>
      <div style={{fontSize:20,fontWeight:800,color:C.charcoal,marginBottom:18}}>الأرباح</div>
      <div style={{background:`linear-gradient(135deg,${C.charcoal},${C.mid})`,borderRadius:24,padding:26,marginBottom:18}}>
        <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:6}}>
          <Ic n="wallet" size={16} color={C.goldLight}/><div style={{fontSize:12,color:"#ffffff99"}}>إيرادات شهرية</div>
        </div>
        <div style={{fontSize:36,fontWeight:900,color:C.white}}>EGP {rev.toLocaleString()}</div>
        <div style={{background:`${C.gold}33`,borderRadius:10,padding:"10px 14px",marginTop:14,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
          <div style={{fontSize:12,color:C.goldLight}}>عمولتك (50%)</div>
          <div style={{fontSize:16,fontWeight:900,color:C.goldLight}}>EGP {Math.round(rev*0.5).toLocaleString()}</div>
        </div>
      </div>
      {apts.map(apt=>{
        const r=apt.rooms.reduce((a,r)=>a+r.beds.filter(b=>b.tenant).reduce((c,b)=>c+b.tenant.rent,0),0);
        const beds=apt.rooms.reduce((a,r)=>a+r.beds.length,0);
        const occ=apt.rooms.reduce((a,r)=>a+r.beds.filter(b=>b.tenant).length,0);
        return(
          <div key={apt.id} style={{background:C.white,border:`1px solid ${C.divider}`,borderRadius:16,padding:16,marginBottom:12}}>
            <div style={{display:"flex",alignItems:"center",gap:10,marginBottom:10}}>
              <Ic n="building" size={16} color={C.gold}/>
              <div style={{fontSize:13,fontWeight:800,color:C.charcoal,flex:1}}>{apt.name}</div>
              <span style={{fontSize:14,fontWeight:900,color:C.gold}}>EGP {r.toLocaleString()}</span>
            </div>
            <div style={{display:"flex",gap:4}}>
              {apt.rooms.flatMap(room=>room.beds).map(b=>(
                <div key={b.id} style={{flex:1,height:6,borderRadius:5,background:b.tenant?C.green:C.divider}}/>
              ))}
            </div>
            <div style={{display:"flex",justifyContent:"space-between",marginTop:6}}>
              <span style={{fontSize:11,color:C.green}}>{occ} ساكن</span>
              <span style={{fontSize:11,color:C.slate}}>{beds-occ} فاضي</span>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ─── MAIN APP ─────────────────────────────────────────────────────────────────
export default function App(){
  const [tab,setTab]=useState(0);
  const [apts,setApts]=useState(initApts);
  const [modal,setModal]=useState(null);
  const [showAddApt,setShowAddApt]=useState(false);
  const [showAddTenant,setShowAddTenant]=useState(false);
  const [callReminder,setCallReminder]=useState(null);

  const closeModal=()=>setModal(null);
  const handleAddTenant=data=>{const{apt,room,bed}=modal;setApts(p=>p.map(a=>a.id!==apt.id?a:{...a,rooms:a.rooms.map(r=>r.id!==room.id?r:{...r,beds:r.beds.map(b=>b.id!==bed.id?b:{...b,tenant:{...data,paid:true}})})}));closeModal();};
  const handleRemoveTenant=()=>{const{apt,room,bed}=modal;setApts(p=>p.map(a=>a.id!==apt.id?a:{...a,rooms:a.rooms.map(r=>r.id!==room.id?r:{...r,beds:r.beds.map(b=>b.id!==bed.id?b:{...b,tenant:null})})}));closeModal();};
  const handleEditTenant=data=>{const{apt,room,bed}=modal;setApts(p=>p.map(a=>a.id!==apt.id?a:{...a,rooms:a.rooms.map(r=>r.id!==room.id?r:{...r,beds:r.beds.map(b=>b.id!==bed.id?b:{...b,tenant:{...b.tenant,...data}})})}));closeModal();};
  const handleAddTenantGlobal=data=>{setApts(p=>p.map(a=>a.id!==data.aptId?a:{...a,rooms:a.rooms.map(r=>r.id!==data.roomId?r:{...r,beds:r.beds.map(b=>b.id!==data.bedId?b:{...b,tenant:{name:data.name,phone:data.phone,rent:data.rent,since:data.since,paid:true}})})}));setShowAddTenant(false);};

  const unpaidCount=apts.reduce((a,ap)=>a+ap.rooms.reduce((b,r)=>b+r.beds.filter(bd=>bd.tenant&&!bd.tenant.paid).length,0),0);

  const navDef=[
    {n:"home",l:"الرئيسية",t:0,badge:0},
    {n:"building",l:"الشقق",t:1,badge:0},
    {n:null,l:"",t:-1},
    {n:"users",l:"العملاء",t:3,badge:unpaidCount},
    {n:"wallet",l:"الأرباح",t:4,badge:0},
  ];

  return(
    <div style={{display:"flex",justifyContent:"center",alignItems:"center",minHeight:"100vh",background:"linear-gradient(135deg,#1a1a2e,#16213e,#0f3460)",fontFamily:font}}>
      <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&display=swap" rel="stylesheet"/>
      <div style={{width:390,height:844,background:C.cream,borderRadius:46,overflow:"hidden",position:"relative",boxShadow:"0 40px 80px #000a,0 0 0 1px #ffffff18",display:"flex",flexDirection:"column"}}>
        {/* Status bar */}
        <div style={{background:tab===0?C.charcoal:C.cream,padding:"13px 30px 8px",display:"flex",justifyContent:"space-between",flexShrink:0}}>
          <span style={{fontSize:12,fontWeight:700,color:tab===0?C.white:C.charcoal}}>9:41</span>
          <span style={{fontSize:12,color:tab===0?C.white:C.charcoal}}>▲▲▲ ▮▮▮</span>
        </div>

        {/* Screen */}
        <div style={{flex:1,overflow:"hidden",position:"relative"}}>
          {tab===0&&<HomeScreen apts={apts} setTab={setTab}/>}
          {tab===1&&<ApartmentsScreen apts={apts} setApts={setApts} setModal={setModal}/>}
          {tab===3&&<ClientsScreen apts={apts} setApts={setApts} setShowAddTenant={setShowAddTenant}/>}
          {tab===4&&<EarningsScreen apts={apts}/>}

          {modal?.type==="addTenant"&&<AddTenantWithPickerModal apts={apts} onClose={closeModal} onSave={data=>handleAddTenant({name:data.name,phone:data.phone,rent:data.rent,since:data.since}) } preselectedApt={modal.apt}/>}
          {modal?.type==="viewTenant"&&!modal.editing&&(
            <TenantDetailSheet bed={modal.bed} aptName={modal.apt.name} roomName={modal.room.name} onClose={closeModal}
              onEdit={()=>setModal({...modal,editing:true})}
              onRemove={handleRemoveTenant}
              onCallReminder={()=>setCallReminder(modal.bed.tenant)}/>
          )}
          {modal?.type==="viewTenant"&&modal.editing&&(
            <EditTenantModal bed={modal.bed} aptName={modal.apt.name} roomName={modal.room.name} onClose={closeModal} onSave={handleEditTenant}/>
          )}
          {showAddApt&&<AddAptModal onClose={()=>setShowAddApt(false)} onSave={a=>{setApts(p=>[...p,a]);setShowAddApt(false);setTab(1);}}/>}
          {showAddTenant&&<AddTenantWithPickerModal apts={apts} onClose={()=>setShowAddTenant(false)} onSave={handleAddTenantGlobal}/>}
          {callReminder&&<CallReminderToast tenant={callReminder} onClose={()=>setCallReminder(null)}/>}
        </div>

        {/* Bottom Nav */}
        <div style={{background:C.white,borderTop:`1px solid ${C.divider}`,padding:"10px 12px 18px",display:"flex",justifyContent:"space-around",alignItems:"center",flexShrink:0,direction:"rtl",zIndex:20}}>
          {navDef.map((item,i)=>{
            if(!item.n) return(
              <button key="fab" onClick={()=>setShowAddApt(true)} style={{width:58,height:58,borderRadius:99,background:C.gold,border:"none",cursor:"pointer",boxShadow:`0 6px 22px ${C.gold}66`,display:"flex",alignItems:"center",justifyContent:"center",marginTop:-22}}>
                <Ic n="plus" size={26} color={C.white} strokeWidth={2.5}/>
              </button>
            );
            const active=tab===item.t;
            return(
              <button key={item.l} onClick={()=>setTab(item.t)} style={{display:"flex",flexDirection:"column",alignItems:"center",gap:4,background:active?C.goldSurface:"none",border:"none",padding:"7px 13px",borderRadius:14,cursor:"pointer",position:"relative"}}>
                <Ic n={item.n} size={22} color={active?C.gold:C.slate} strokeWidth={active?2.2:1.7}/>
                <span style={{fontSize:10,fontWeight:active?800:400,color:active?C.gold:C.slate,fontFamily:font}}>{item.l}</span>
                {item.badge>0&&<div style={{position:"absolute",top:4,right:10,width:16,height:16,background:C.red,borderRadius:99,display:"flex",alignItems:"center",justifyContent:"center",fontSize:9,color:C.white,fontWeight:800}}>{item.badge}</div>}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
