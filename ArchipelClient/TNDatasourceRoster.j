/*  
 * TNDatasourceRoster.j
 *    
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <StropheCappuccino/StropheCappuccino.j>

/*! @global
    @group TNDragType
    Drag type for contacts
*/
TNDragTypeContact   = @"TNDragTypeContact";

/*! @ingroup archipelcore
    Subclass of TNStropheRoster that allow TNOutlineViewRoster to use it as Data Source.
*/
@implementation TNDatasourceRoster  : TNStropheRoster 
{
    CPOutlineView   mainOutlineView @accessors;
    CPString        filter          @accessors;
    CPSearchField   filterField     @accessors;

    id              _draggedItem;
}

/*! init the datasource
    @param aConnection a valid connected TNStropheConnection
    @return initialized instance of TNDatasourceRoster
*/
- (id)initWithConnection:(TNStropheConnection)aConnection
{
    if (self = [super initWithConnection:aConnection])
    {
        [self setFilter:nil];
        
        // register for notifications that should trigger outlineview reload
        var center = [CPNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updateOutlineView:) name:TNStropheRosterRetrievedNotification object:nil];
        [center addObserver:self selector:@selector(updateOutlineViewAndKeepOldSelection:) name:TNStropheRosterRemovedContactNotification object:nil];
        [center addObserver:self selector:@selector(updateOutlineViewAndKeepOldSelection:) name:TNStropheRosterAddedContactNotification object:nil];
        
        [center addObserver:self selector:@selector(updateOutlineViewItem:) name:TNStropheContactPresenceUpdatedNotification object:nil];
        [center addObserver:self selector:@selector(updateOutlineView:) name:TNStropheContactNicknameUpdatedNotification object:nil];
        [center addObserver:self selector:@selector(updateOutlineView:) name:TNStropheContactGroupUpdatedNotification object:nil];
        
        [center addObserver:self selector:@selector(updateOutlineView:) name:TNStropheRosterAddedGroupNotification object:nil];
        
        [center addObserver:self selector:@selector(updateOutlineViewAndKeepOldSelection:) name:TNStropheContactMessageReceivedNotification object:nil];
        [center addObserver:self selector:@selector(updateOutlineViewAndKeepOldSelection:) name:TNStropheContactMessageTreatedNotification object:nil];
    }
     
    return self;
}

/*! allow to define a CPSearchField to filter entries
    @param aField CPSearchField to use for filtering
*/
- (void)setFilterField:(CPSearchField)aField
{
    filterField = aField;
    
    [[self filterField] setSendsSearchStringImmediately:YES]
    [[self filterField] setTarget:self];
    [[self filterField] setAction:@selector(filterFieldDidChange:)];
}

/*! Action that will be plugged to the CPSearchField in order to catch
    when user changes the value
*/
- (IBAction)filterFieldDidChange:(id)sender
{
    [self setFilter:[sender stringValue]];
    [self updateOutlineView:nil];
}


/*! Reload the content of the datasource and try to keep the old selection
    @param aNotification CPNotification that trigger the message
*/
- (void)updateOutlineViewAndKeepOldSelection:(CPNotification)aNotification 
{
    [[self mainOutlineView] reloadData];
}

/*! Reload the content of the datasource
    @param aNotification CPNotification that trigger the message
*/
- (void)updateOutlineView:(CPNotification)aNotification 
{
    [[self mainOutlineView] reloadData];
    
    var index   = [[self mainOutlineView] rowForItem:[aNotification object]];
    
    if (index != -1)
    {
        var set     = [CPIndexSet indexSetWithIndex:index];
        [[self mainOutlineView] selectRowIndexes:set byExtendingSelection:NO];
    }
}

/*! Reload the content of the item given as object of aNotification
    @param aNotification CPNotification that trigger the message
*/
- (void)updateOutlineViewItem:(CPNotification)aNotification
{
    [[self mainOutlineView] reloadData];
    //[[self outlineView] reloadItem:[aNotification object]];
}

/*! Reload the content of the group given as object of aNotification
    @param aNotification CPNotification that trigger the message
*/
- (void)updateOutlineViewGroupItem:(CPNotification)aNotification
{
    [[self mainOutlineView] reloadData];
    //[[self outlineView] reloadItem:[self getGroup:[[aNotification object] group]]];
}

/*! Message use internally for filtering
    @param aFilter CPString containing the filter
    @return a CPArray containing the contacts that matches the filters
*/
- (CPArray)_getEntriesMatching:(CPString)aFilter 
{
    var theEntries      = [self entries];
    var filteredEntries = [[CPArray alloc] init];
    var i;
    
    if (!aFilter)
        return theEntries;
    
    //@each (var entry in theEntries)
    for(var i = 0; i < [theEntries count]; i++)
    {
        var entry = [theEntries objectAtIndex:i];
        
        if ([[entry nickname] uppercaseString].indexOf([aFilter uppercaseString]) != -1)
            [filteredEntries addObject:entry]
    }
    return filteredEntries;
}

/*! Message use internally for filtering
    @param aFilter CPString containing the filter
    @param inGroup CPString containing the group of filter
    @return a CPArray containing the contacts in aGroup that matches the filters
*/
- (CPArray)_getEntriesMatching:(CPString)aFilter inGroup:(CPString)aGroup
{
    var theEntries      = [self getContactsInGroup:aGroup];
    var filteredEntries = [[CPArray alloc] init];
    var i;
    
    if (!aFilter)
        return theEntries;
    
    //@each (var entry in theEntries)
    for(var i = 0; i < [theEntries count]; i++)
    {
        var entry = [theEntries objectAtIndex:i];
        
        if ([[entry nickname] uppercaseString].indexOf([aFilter uppercaseString]) != -1)
            [filteredEntries addObject:entry];
    }
    
    return filteredEntries;
}


/*! Message use internally for filtering
    @param aFilter CPString containing the filter
    @return a CPArray groups containing contacts matching aFilter
*/
- (CPArray)_getGroupContainingEntriesMatching:(CPString)aFilter
{
    var theGroups      = [self groups];
    var filteredGroup   = [[CPArray alloc] init];
    var i;
    
    if (!aFilter)
        return [self groups];
        
    //@each (var group in theGroups)
    for(var i = 0; i < [theGroups count]; i++)
    {
        var group = [theGroups objectAtIndex:i];
        
        if ([[self _getEntriesMatching:aFilter inGroup:[group name]] count] > 0)
            [filteredGroup addObject:group];
    }
    
    return filteredGroup;
}


/*! CPOutlineView Delegate
*/
- (BOOL)outlineView:(CPOutlineView)anOutlineView writeItems:(CPArray)theItems toPasteboard:(CPPasteBoard)thePasteBoard
{
    var draggedItem = [theItems objectAtIndex:0];
    if ([draggedItem type] == @"group")
        return NO;
    
    _draggedItem = [theItems objectAtIndex:0];
    
    [thePasteBoard declareTypes:[TNDragTypeContact] owner:self];    
    [thePasteBoard setData:[CPKeyedArchiver archivedDataWithRootObject:theItems] forType:TNDragTypeContact];
    
    return YES;
}


/*! CPOutlineView Delegate
*/
- (int)outlineView:(CPOutlineView)anOutlineView numberOfChildrenOfItem:(id)item 
{
    if (!item) 
    {
	    return [[self _getGroupContainingEntriesMatching:[self filter]] count];
	}
	else 
	{
	    return [[self _getEntriesMatching:[self filter] inGroup:item] count];
	}
}

/*! CPOutlineView Delegate
*/
- (BOOL)outlineView:(CPOutlineView)anOutlineView isItemExpandable:(id)item 
{
	return ([item type] == @"group") ? YES : NO;
}

/*! CPOutlineView Delegate
*/
- (id)outlineView:(CPOutlineView)anOutlineView child:(int)index ofItem:(id)item  
{
    if (!item) 
    {
        return [[self _getGroupContainingEntriesMatching:[self filter]].sort() objectAtIndex:index];
    }
    else 
    {
        return [[self _getEntriesMatching:[self filter] inGroup:[item name]].sort() objectAtIndex:index];
    }
}

/*! CPOutlineView Delegate
*/
- (id)outlineView:(CPOutlineView)anOutlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item 
{
    var cid = [tableColumn identifier];

    if (cid == @"nickname")
    {
        return item;
    }
    // else if (cid == @"statusIcon") 
    // {
    //     if ([item type] == @"contact")
    //         return [item statusIcon];
    //     else
    //         return nil;
    // }
}

/*! CPOutlineView Delegate
*/
- (CPDragOperation)outlineView:(CPOutlineView)anOutlineView validateDrop:(id < CPDraggingInfo >)theInfo proposedItem:(id)theItem proposedChildIndex:(int)theIndex
{
    if ([theItem type] != @"group")
         return CPDragOperationNone;
           
    [anOutlineView setDropItem:theItem dropChildIndex:theIndex];
   
    return CPDragOperationEvery;
}

/*! CPOutlineView Delegate
*/
- (BOOL)outlineView:(CPOutlineView)anOutlineView acceptDrop:(id < CPDraggingInfo >)theInfo item:(id)theItem childIndex:(int)theIndex
{
    [_draggedItem changeGroup:[theItem name]];
    [[self mainOutlineView] reloadData];
    
    return YES;
}

@end